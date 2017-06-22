#! /usr/bin/env ruby

require 'aws-sdk'
require 'inifile'
require 'optparse'
require 'yaml'

class Command
  def initialize(args)
    @args = args
  end

  def execute
    items = Loader.new(@args).load
    selected_item = IO.popen('percol', 'r+') do |io|
      io.puts items
      io.close_write
      io.gets
    end

    if selected_item.is_a? String
      ssh_args = selected_item.split("\t")[1]
      execute_ssh(ssh_args)
    else
      puts 'No item selected.'
    end
  end

  private

  def execute_ssh(args)
    cmd = "ssh -A #{args}"
    puts cmd
    system(cmd)
  end
end

class Loader
  CONFIG = File.join(Dir.home, '.aws', 'config').freeze
  CACHE = File.join(Dir.home, '.ec2ssh').freeze
  CACHE_TTL = 3600
  INSTANCE = Struct.new(:instance_id, :public_dns_name, :private_dns_name, :tags)

  def initialize(args)
    @args = args
    @ignore_cache = false
    @instances = []
    @profile = 'default'
  end

  def load
    accept_command_line_options
    setup_aws_sdk
    load_instances
    print_loaded_instances
  end

  private

  def accept_command_line_options
    region = ENV['REGION']

    OptionParser.new do |opt|
      opt.banner = "Usage: #{opt.program_name} [options]"
      opt.on('-f', '--flush', 'Flush cache') { @ignore_cache = true }
      opt.on('-h', '--help', 'Show usage') { puts opt.help ; exit }
      opt.on('-p PROFILE', '--profile PROFILE', 'Specify profile') do |v|
        @profile = v
      end
      opt.on('-r REGION', '--region REGION', 'Specify region') { |v| region = v }
      opt.parse!(@args)
    end

    ini = IniFile.load(CONFIG)
    @region = region || ini[@profile]['region']
  end

  def setup_aws_sdk
    Aws.config[:credentials] = Aws::SharedCredentials.new(profile_name: @profile)
    Aws.config[:region] = @region
  end

  def load_instances
    @instances = load_instances_from_cache || load_instances_from_endpoint
  end

  def load_instances_from_cache
    instances = nil

    if File.exist?(CACHE) && !@ignore_cache
      mtime = File::Stat.new(CACHE).mtime
      if Time.now - mtime < CACHE_TTL
        cache = YAML.load_file(CACHE)
        instances = cache[@profile][@region] rescue nil
      end
    end

    instances
  end

  def load_instances_from_endpoint
    ec2 = Aws::EC2::Client.new

    filters = [{ name: 'instance-state-name', values: ['running'] }]
    instances = ec2.describe_instances(filters: filters).reservations.flat_map(&:instances).map! do |instance|
      INSTANCE.new(
        instance.instance_id,
        instance.public_dns_name,
        instance.private_dns_name,
        instance.tags)
    end

    File.open(CACHE, 'w') do |f|
      cache = { @profile => { @region => instances } }
      YAML.dump(cache, f)
    end

    instances
  end

  def print_loaded_instances
    @instances.map do |instance|
      user = 'ec2-user'
      name = instance.instance_id
      dnsname = instance.public_dns_name || instance.private_dns_name
      instance.tags.each do |tag|
        name = tag.value if tag.key =~ /^name/i
        user = tag.value if tag.key =~ /^user/i
      end
      "\"#{name}\"\t#{user}@#{dnsname}\t#{instance.instance_id}"
    end
  end
end

Command.new(ARGV).execute
