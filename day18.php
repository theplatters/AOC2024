<?php

class Graph
{
    private $adjacencyList;

    public function __construct()
    {
        $this->adjacencyList = [];
    }

    // Add a vertex to the graph
    public function addVertex($vertex): void
    {
        $key = $this->key($vertex);
        if (!array_key_exists($key, $this->adjacencyList)) {
            $this->adjacencyList[$key] = [];
        }
    }

    // Add an edge between two vertices
    public function addEdge($vertex1, $vertex2): void
    {
        $this->addVertex($vertex1);
        $this->addVertex($vertex2);

        $key1 = $this->key($vertex1);
        $key2 = $this->key($vertex2);

        if (!in_array($vertex2, $this->adjacencyList[$key1])) {
            $this->adjacencyList[$key1][] = $vertex2;
        }
        if (!in_array($vertex1, $this->adjacencyList[$key2])) {
            $this->adjacencyList[$key2][] = $vertex1;
        }
    }
    // Remove a vertex and all its associated edges
    public function removeVertex($vertex): void
    {
        $key = $this->key($vertex);

        // Remove all edges to this vertex
        if (array_key_exists($key, $this->adjacencyList)) {
            foreach ($this->adjacencyList[$key] as $neighbor) {
                $neighborKey = $this->key($neighbor);
                $this->adjacencyList[$neighborKey] = array_filter(
                    $this->adjacencyList[$neighborKey],
                    fn ($v) => $v !== $vertex
                );
            }

            // Remove the vertex from the adjacency list
            unset($this->adjacencyList[$key]);
        }
    }
    public function shortestPath($start, $end)
    {
        // Initialize distance array and queue
        $distances = [];
        $previous = [];
        $queue = new SplQueue();

        $startKey = $this->key($start);
        $endKey = $this->key($end);

        // Set initial distances to infinity and start distance to 0
        foreach ($this->adjacencyList as $vertex => $neighbors) {
            $distances[$vertex] = INF;
            $previous[$vertex] = null;
        }
        $distances[$startKey] = 0;

        // Enqueue the start vertex
        $queue->enqueue($startKey);

        while (!$queue->isEmpty()) {
            $currentVertex = $queue->dequeue();
            // Explore neighbors
            foreach ($this->adjacencyList[$currentVertex] as $neighbor) {
                $neighborKey = $this->key($neighbor);
                $dist = $distances[$currentVertex] + 1;
                if ($dist < $distances[$neighborKey]) {
                    $distances[$neighborKey] = $dist;
                    $queue->enqueue($neighborKey);
                }
            }
        }
        return $distances[$endKey];
    }


    // Helper: Convert a vertex to a string key
    private function key($vertex): string
    {
        return implode(",", $vertex);
    }
}

class GraphFactory
{
    /**
     * @return Graph
     * @param mixed $rows
     * @param mixed $cols
     */
    public static function createGridGraph($rows, $cols): Graph
    {
        $graph = new Graph();

        for ($x = 0; $x < $rows; $x++) {
            for ($y = 0; $y < $cols; $y++) {
                $current = [$x, $y];

                // Connect to adjacent cells
                $neighbors = [
                    [$x - 1, $y], // Up
                    [$x + 1, $y], // Down
                    [$x, $y - 1], // Left
                    [$x, $y + 1]  // Right
                ];
                foreach ($neighbors as $neighbor) {
                    if (self::_isValid($neighbor, $rows, $cols)) {
                        $graph->addEdge($current, $neighbor);
                    }
                }
            }
        }

        return $graph;
    }

    // Helper: Check if a vertex is within bounds
    private static function _isValid($vertex, $rows, $cols): bool
    {
        return $vertex[0] >= 0 && $vertex[0] < $rows && $vertex[1] >= 0 && $vertex[1] < $cols;
    }
}

// Example usage
$rows = 71;
$cols = 71;

// Create the grid graph using the factory
$gridGraph = GraphFactory::createGridGraph($rows, $cols);

$myfile = fopen("input18.txt", "r") or die("Unable to open file!");
$content = explode("\n", fread($myfile, filesize("input18.txt")));

$data = array_map(function ($x) {
    return array_map('intval', explode(',', $x));
}, $content);



foreach (array_slice($data, 0, 1024) as $ram) {
    $gridGraph->removeVertex($ram);
}

$dist = $gridGraph->shortestPath([0, 0], [70, 70]);
echo $dist, "\n";

foreach ($data as $ram) {
    $gridGraph->removeVertex($ram);
    $dist = $gridGraph->shortestPath([0, 0], [70, 70]);
    if ($dist == INF) {
        echo implode(',', $ram), "\n";
        break;
    }
};
