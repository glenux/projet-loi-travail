#!/usr/bin/env ruby

require 'fileutils'

class Splitter
  def initialize
    @chapitre = ""
    @article = ""
    @titre = ""
    @document = "INTRODUCTION.txt"
  end

  def update what
    if what[:titre] then
      @titre = what[:titre] if what[:titre]
      @chapitre = ""
      @article = ""
    end
    if what[:chapitre] then
      @chapitre = what[:chapitre]
      @article = ""
    end
    if what[:article] then
      @article = what[:article]
    end
    @document = ""
    @document += "TITRE #{@titre}" unless @titre.empty?
    @document += " - CHAPITRE #{@chapitre}" unless @chapitre.empty?
    @document += " - ARTICLE #{@article}" unless @article.empty?
    @document += ".txt"
    FileUtils.rm_f @document
    puts @document
  end

  def parse filename
    File.readlines(filename).each do |line|
      md_prefix = ''
      line = line.strip

      case line 
      when /^TITRE\s+(.*)/     then update titre: $1
        md_prefix="# "
      when /^CHAPITRE\s+(.*)/ then update chapitre: $1
        md_prefix="## "
      when /^Article\s+(.*)/  then update article: $1
        md_prefix="### "
      end

      unless line.empty? then
        File.open(@document,'a') do |fh|
          fh.puts(md_prefix + line)
        end
      end
    end
  end
end

app = Splitter.new 
app.parse ARGV[0]

