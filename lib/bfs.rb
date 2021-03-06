# -*- coding: utf-8 -*-
class BreadthFirstSearch
  class Node
    attr_reader :name
    attr_reader :neighbors
    attr_accessor :distance
    attr_reader :prev

    def initialize(name, neighbors)
      @name = name
      @neighbors = neighbors
      @distance = 100_000
      @prev = nil
    end

    def maybe_update_distance_and_prev(min_node)
      new_distance = min_node.distance + 1
      return if new_distance > @distance
      @distance = new_distance
      @prev = min_node
    end

    def <=>(other)
      @distance <=> other.distance
    end
  end

  class SortedArray
    def initialize(array)
      @array = []
      array.each { |each| @array << each }
      @array.sort!   #@arrayを昇順にソート
    end

    def method_missing(method, *args)
      result = @array.__send__ method, *args
      @array.sort!
      result
    end
  end

  def initialize(graph)
    @graph = graph
    @visited = []
    @edge_to = {}

    @all = graph.map { |name, neighbors| Node.new(name, neighbors) }   #name, neighborsを初期化したものを配列で返す
    @unvisited = SortedArray.new(@all)
    @undecided_nodes = []
    for node in @all do
      @undecided_nodes.append(node.name)
    end
  end

  def shortest_path_to(start, node)
    return unless has_path_to?(node)
    path = []

    while(node != start) do
      path.unshift(node)
      node = @edge_to[node]
    end

    path.unshift(start)
  end

  def run(start, goal)
    start_node = find(start, @all)
    goal_node = find(goal, @all)

    queue = []
    tmp = []

    tmp << start_node.name
    queue << tmp
    File.delete "./output/path.js"
    fhtml = open("./output/path.js", "w")
    fhtml.write("paths = [];\n")
    fhtml.close()
    @visited << start_node.name
    ans = search(queue, goal_node, 0)

    return ans.last

  end

  private

  def has_path_to?(node)
    @visited.include?(node)
  end

  def path_to(goal)
    [find(goal, @all)].tap do |result|
      result.unshift result.first.prev while result.first.prev
    end.map(&:name)
  end

  def find(name, list)
    found = list.find { |each| each.name == name }
    fail "Node #{name.inspect} not found" unless found
    found
  end

  def print_path(queue, index, is_last=false)
    prev_id = nil
    outtext = ""
    outtext +="paths.push([]);\n"
    queue.each do |qeach|
      flag = true
      qeach.each do |each|
        if each.instance_of?(Pio::Mac) then
          id = each
        elsif each.is_a?(Integer) then
          next
        else
          id = each[0]
        end
        if prev_id == id then
          next
        end
        if flag == true then
          flag = false
          prev_id = id
          next
        end
        outtext += "paths[%d].push({from:%d, to: %d });\n"% [index, prev_id, id]
        prev_id = id
      end
  end
  fhtml = open("./output/path.js", "a")
  # fhtml.write(ERB.new(File.open('./output/template/topology_template.js').read).result(binding))
  fhtml.write(outtext)
  fhtml.close()
  if is_last then
    tmp = []
    tmp << queue.last
    print_path(tmp, index+1)
  end
 
  end


  def search(queue, goal, i)
    print_path(queue,i)
    start_node_tmp = queue[0]
    start_node = start_node_tmp[0]



    while queue[0].length == i+1 do
      list = []
      current_node_name_tmp = queue.shift
      current_node_name = current_node_name_tmp[i]
      current_node = find(current_node_name, @all)
      current_node.neighbors.each do |adjacent_node|
        neighbor = adjacent_node
        next if @visited.include?(neighbor)
        list.append(neighbor)
        @visited << neighbor
      end
      puts @visited
      puts "------------------------------"
      puts list
      puts "----------------------------------"

      list.each do |n|
        tmp = Array.new(current_node_name_tmp)
        tmp.append(n)
        queue.append(tmp)
        if n == goal.name
          print_path(queue, i, true)
          return queue
        end
      end
    end
    return search(queue, goal, i+1)
  end
end
