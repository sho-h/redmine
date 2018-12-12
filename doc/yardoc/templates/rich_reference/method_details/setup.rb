# frozen_string_literal: true

require 'redmine/version'

def init
  # TODO: Commonize with fulldoc like helper method.
  redmine_ver =
    Gem::Version.new(Redmine::VERSION.to_s.gsub(/\.(stable|devel)\z/, ''))

  $redmine_changes.select { |c|
    c[:class_or_method] == object.to_s
  }.reject { |c|
    v = Gem::Version.new(c[:version])
    (c[:event] == :added && v > redmine_ver) || (c[:event] == :removed && v < redmine_ver)
  }.each do |change|
    yard_event = {added: :since, removed: :deprecated}[change[:event]]
    if tags = object.tags(yard_event).empty?
      case yard_event
      when :since
        object.add_tag(YARD::Tags::Tag.new(:since, change[:version]))
      when :deprecated
        object.add_tag(YARD::Tags::Tag.new(:deprecated, "Removed at #{change[:version]}"))
      end
    end
  end

  sections :header, [:method_signature, T('docstring'), :source]
end

def source
  return if owner != object.namespace
  return if Tags::OverloadTag === object
  return if object.source.nil?
  erb(:source)
end
