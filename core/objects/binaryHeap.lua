local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap

-- Create a new BinaryHeap object
function BinaryHeap.new()
    return setmetatable({heap = {}}, BinaryHeap)
end

-- Helper function to maintain heap order (heapify-up)
local function heapifyUp(heap, index)
    local parentIndex = math.floor(index / 2)
    if parentIndex >= 1 and heap[parentIndex].priority < heap[index].priority then
        heap[parentIndex], heap[index] = heap[index], heap[parentIndex]
        heapifyUp(heap, parentIndex)
    end
end

-- Helper function to maintain heap order (heapify-down)
local function heapifyDown(heap, index)
    local leftChild = 2 * index
    local rightChild = 2 * index + 1
    local largest = index

    if leftChild <= #heap and heap[leftChild].priority > heap[largest].priority then
        largest = leftChild
    end
    if rightChild <= #heap and heap[rightChild].priority > heap[largest].priority then
        largest = rightChild
    end
    if largest ~= index then
        heap[largest], heap[index] = heap[index], heap[largest]
        heapifyDown(heap, largest)
    end
end

-- Insert an element into the heap (with priority)
function BinaryHeap:insert(state, priority, args, keyData, bufferData)
    table.insert(self.heap, {state = state, priority = priority, args = args, keyData = keyData, bufferData = bufferData})
    heapifyUp(self.heap, #self.heap)
end

-- Remove and return the element with the highest priority (root)
function BinaryHeap:removeMax()
    if #self.heap == 0 then return nil end
    local max = self.heap[1]
    self.heap[1] = self.heap[#self.heap]
    table.remove(self.heap)
    heapifyDown(self.heap, 1)
    return max
end

-- Return the size of the heap
function BinaryHeap:size()
    return #self.heap
end

return BinaryHeap