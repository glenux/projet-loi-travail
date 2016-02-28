#!/usr/bin/env ruby

require 'fileutils'

class Splitter
  def initialize
    @article_desc = ""
    @article_id = 0
    @chapitre_desc = ""
    @chapitre_id = 0
    @titre_desc = ""
    @titre_id = 0
    @document = "INTRODUCTION.md"
  end

  def update_intro struct
    document = "INTRODUCTION.md"
    File.open(document,'w') do |fh|
      fh.puts struct[:undef]
    end
  end

  def update_content struct
    document = ""
    document += "TITRE #{struct[:titre_id]}"
    document += " - CHAPITRE #{struct[:chapitre_id]}"
    document += " - ARTICLE %02d" % struct[:article_id]
    document += ".md"
    
    File.open(document,'w') do |fh|
      fh.puts "# TITRE #{struct[:titre_id]} - #{struct[:titre]}\n\n"
      fh.puts "## CHAPITRE #{struct[:chapitre_id]} - #{struct[:chapitre]}\n\n"
      fh.puts "### ARTICLE %d\n\n" % struct[:article_id]
      fh.puts struct[:article]
    end
  end

  def parse filename
    prev_level = nil
    cur_level = :undef
    cur_id = 0
    struct = {
      undef: "",
      titre: "",
      titre_id: 0,
      chapitre: "",
      chapitre_id: 0,
      article: "",
      article_id: 0
    }

    File.readlines(filename).each do |line|
      prev_level = cur_level
      prev_id = cur_id
      line = line.strip

      next if line.nil?

      case line 
      when /^TITRE\s+(.*)/     then 
        cur_level = :titre
        cur_id = _arabic_of $1
      when /^CHAPITRE\s+(.*)/ then 
        cur_level = :chapitre
        cur_id = _arabic_of $1
      when /^Article\s+(.*)/  then 
        cur_level = :article
        cur_id = $1.to_i
      end

      if cur_level == prev_level && cur_id == prev_id then
        # Same level - append data to current level
        puts "%s %s" % [cur_level, cur_id]

        # add new paragraph if needed
        if line =~ /^(«|-|\w+\)|\w+°|[IXV]+\.)/ then line = "\n" + line end

        # add markdown for section
        line.gsub!(/« (Section.*)/,'« **\1**')

        case cur_level
        when :article, :undef then
          struct[cur_level] += line + "\n"
        when :titre, :chapitre then
          struct[cur_level] += line + ' '
        end
      else
        # We changed level
        case prev_level 
        when :article then
          puts struct[:article]
          update_content struct
          struct[:article] = ''
        when :undef then
          update_intro struct
          struct[:undef] = ""
        end
        id_sym = (cur_level.to_s + '_id').to_sym 
        struct[id_sym] = cur_id
      end
    end
    update_content struct
  end

  private

  def _arabic_of txt
    table={
      'IER'  => 1,
      'II'   => 2,
      'III'  => 3,
      'IV'   => 4,
      'V'    => 5,
      'VI'   => 6,
      'VII'  => 7,
      'VIII' => 8,
      'IX'   => 9,
      'X'    => 10
    }
    table[txt]
  end
end

app = Splitter.new 
app.parse ARGV[0]

