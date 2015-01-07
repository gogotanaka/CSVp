require 'minitest_helper'
require 'csv'
require 'pry'
class CSV::Table

  def uniq(sym_or_num=nil, &blk)
    table.map{|e|e}.uniq { |e| e[sym_or_num] }
  end
end

class CSVp
  attr_reader :csv, :path

  def initialize(path)
    @csv = CSV.table(File.expand_path(path)) 
    @path = path
  end

  def <<(row)
    CSV.open(File.expand_path(@path), "ab") { |csv| csv << row }
    self
  end

  def output!(rows)
    CSV.open(File.expand_path(@path), "wb") { |csv| rows.each { |row| csv << row } }
  end
  
  def reload
    @csv = CSV.table(File.expand_path(path)) 
  end

  def group_by(sym_or_num)
    @csv.group_by { |e| e[sym_or_num] }
  end

  def map_col!(sym_or_num, &blk)
    output! @csv.each{ |row| row[sym_or_num] = blk.call row[sym_or_num] }.to_a
    reload
    to_a
  end

  def map(&blk)
    binding.pry
  end

  def method_missing(mth, *args, &blk)
    @csv.send(mth, *args, &blk)
  end
end
class TestCSVp < MiniTest::Unit::TestCase
  def setup
    @csvp = CSVp.new(File.dirname(__FILE__) + '/data.csv')
  end

  def test_main
    assert_equal(@csvp[1][1], 90)
    assert_equal(@csvp.group_by(:name).to_s, "{\"Tom\"=>[#<CSV::Row name:\"Tom\" point:23>, #<CSV::Row name:\"Tom\" point:92>], \"Bob\"=>[#<CSV::Row name:\"Bob\" point:90>]}")
    assert_equal(@csvp.uniq(:name).to_s, "[#<CSV::Row name:\"Tom\" point:23>, #<CSV::Row name:\"Bob\" point:90>]")

    assert_equal(@csvp.count, 3)
    @csvp << [1, 2, 3]
    rows = @csvp.to_a
    @csvp.reload
    assert_equal(@csvp.count, 4)
    @csvp.output!(rows)
    @csvp.reload
    assert_equal(@csvp.count, 3)

    assert_equal(@csvp.map_col!(1) { |e| 'TEST' },     [[:name, :point], ["Tom", "TEST"], ["Bob", "TEST"], ["Tom", "TEST"]])
    assert_equal(@csvp.map_col!(:name) { |e| 'TEST' }, [[:name, :point], ["TEST", "TEST"], ["TEST", "TEST"], ["TEST", "TEST"]])
    @csvp.output!(rows)
    binding.pry
  end
end
