class Node
    attr_accessor :next
    attr_reader :value

    def initialize(value)
        @next = nil
        @value = value
    end
end

class LinkedList
    attr_reader :head
    attr_reader :tail

    def initialize
        @head = nil
        @tail = nil
    end

    def append(value)
        if @head
            @tail.next = Node.new(value)
            @tail = @tail.next
        else
            @head = Node.new(value)
            @tail = @head
        end
    end
end
