package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"slices"
	"strings"
)

type IntPair struct {
	First  int
	Second int
}

type Node struct {
	content  []IntPair
	moveable bool
	left     *Node
	right    *Node
}

func (p IntPair) Add(other IntPair) IntPair {
	return IntPair{
		First:  p.First + other.First,
		Second: p.Second + other.Second,
	}
}

func (p IntPair) Sub(other IntPair) IntPair {
	return IntPair{
		First:  p.First - other.First,
		Second: p.Second - other.Second,
	}
}

var dirMap = map[byte]IntPair{
	'^': {0, -1},
	'<': {-1, 0},
	'>': {1, 0},
	'v': {0, 1},
}

const (
	ROBOT   byte = '@'
	PACKAGE      = 'O'
	EMPTY        = '.'
	WALL         = '#'
)

func findIndicesInLine(array [][]byte, start IntPair, direction IntPair) []IntPair {
	rows := len(array)
	if rows == 0 {
		return nil
	}
	cols := len(array[0])

	result := []IntPair{}
	current := start

	// Traverse in the specified direction until out of bounds
	for {
		// Check bounds
		if current.First <= 0 || current.First >= rows || current.Second <= 0 || current.Second >= cols || array[current.Second][current.First] == '#' {
			break
		}
		// Append the current index
		result = append(result, current)
		// Move to the next index in the direction
		current = IntPair{
			First:  current.First + direction.First,
			Second: current.Second + direction.Second,
		}
	}

	return result
}

func findCharIndex(data [][]byte, target byte) (IntPair, bool) {
	for j, outer := range data {
		for i, char := range outer {
			if char == target {
				return IntPair{i, j}, true
			}
		}
	}
	return IntPair{-1, -1}, false
}

func GPSLocation(data [][]byte, target byte) int64 {
	acc := int64(0)
	for j, outer := range data {
		for i, char := range outer {
			if char == target {
				acc += int64(100*j + i)
			}
		}
	}
	return acc
}

func findSegment(direction byte, current IntPair, mapOfFactory [][]byte) []IntPair {
	return findIndicesInLine(mapOfFactory, current, dirMap[direction])
}

func findFirstDot(segment []IntPair, mapOfFactory [][]byte) (IntPair, error) {
	for _, seg := range segment {
		if mapOfFactory[seg.Second][seg.First] == '.' {
			return seg, nil
		}
	}
	return IntPair{0, 0}, errors.New("no free dot found")
}

func moveRobot(current IntPair, segment []IntPair, mapOfFactory [][]byte) IntPair {
	if len(segment) == 0 {
		return current
	}
	firstPoint, err := findFirstDot(segment, mapOfFactory)
	if err != nil {
		return current
	}

	mapOfFactory[current.Second][current.First] = '.'

	lastChar := byte('@')
	for _, index := range segment[1:] {
		temp := mapOfFactory[index.Second][index.First]
		mapOfFactory[index.Second][index.First] = byte(lastChar)
		lastChar = temp
		if index == firstPoint {
			break
		}
	}
	return segment[1]
}

func initLeftRight(node *Node) {
	if node.left == nil { // Initialize the left branch if nil
		node.left = &Node{
			content:  make([]IntPair, 0),
			moveable: false,
		}
	}
	if node.right == nil { // Initialize the right branch if nil
		node.right = &Node{
			content:  make([]IntPair, 0),
			moveable: false,
		}
	}
}

func findYSegment(mapOfFactory [][]byte, current IntPair, direction IntPair, currentNode *Node) {
	rows := len(mapOfFactory)
	cols := len(mapOfFactory[0])

	if currentNode == nil {
		currentNode = &Node{
			content:  make([]IntPair, 0),
			moveable: true,
			left:     nil,
			right:    nil,
		}
	}
	if current.First <= 0 || current.First >= cols || current.Second <= 0 || current.Second >= rows {
		return
	}

	prev := current.Sub(direction)
	switch mapOfFactory[current.Second][current.First] {
	case '[':
		currentNode.content = append(currentNode.content, current)
		if mapOfFactory[prev.Second][prev.First] == '[' {
			findYSegment(mapOfFactory, current.Add(direction), direction, currentNode)
		} else {
			initLeftRight(currentNode)
			currentNode.moveable = true
			findYSegment(mapOfFactory, current.Add(direction), direction, currentNode.left)
			findYSegment(mapOfFactory, current.Add(direction).Add(dirMap['>']), direction, currentNode.right)

		}
	case ']':

		currentNode.content = append(currentNode.content, current)
		currentNode.moveable = true
		if mapOfFactory[prev.Second][prev.First] == ']' {
			findYSegment(mapOfFactory, current.Add(direction), direction, currentNode)
		} else {
			initLeftRight(currentNode)
			findYSegment(mapOfFactory, current.Add(direction), direction, currentNode.right)
			findYSegment(mapOfFactory, current.Add(direction).Add(dirMap['<']), direction, currentNode.left)
		}
	case '.':
		currentNode.moveable = true
		currentNode.content = append(currentNode.content, current)
		return
	case '#':
		return
	}
}

func findXSegment(mapOfFactory [][]byte, start IntPair, direction IntPair, node *Node) {
	rows := len(mapOfFactory)
	cols := len(mapOfFactory[0])

	current := start

	// Traverse in the specified direction until out of bounds
	for {
		// Check bounds
		if current.First <= 0 || current.First >= cols || current.Second <= 0 || current.Second >= rows || mapOfFactory[current.Second][current.First] == '#' {
			break
		}

		node.content = append(node.content, current)
		if mapOfFactory[current.Second][current.First] == '.' {
			node.moveable = true
			return
		}
		// Append the current index
		// Move to the next index in the direction
		current = current.Add(direction)
	}
}

func findSegment2(direction byte, current IntPair, mapOfFactory [][]byte) Node {
	currentNode := Node{
		content:  make([]IntPair, 0),
		moveable: false,
		left:     nil,
		right:    nil,
	}

	if direction == '<' || direction == '>' {
		findXSegment(mapOfFactory, current.Add(dirMap[direction]), dirMap[direction], &currentNode)
	} else {
		findYSegment(mapOfFactory, current.Add(dirMap[direction]), dirMap[direction], &currentNode)
	}
	return currentNode
}

func removeLeafs(root *Node) (*Node, []*Node) {
	if root == nil {
		return nil, nil
	}

	// Check if the current node is a leaf.
	if root.left == nil && root.right == nil {
		// This node is a leaf, so "remove" it by returning nil and the node itself.
		return nil, []*Node{root}
	}

	// Recursively process left and right subtrees.
	var removedLeafs []*Node
	if root.left != nil {
		root.left, removedLeafs = removeLeafs(root.left)
	}
	if root.right != nil {
		var rightLeafs []*Node
		root.right, rightLeafs = removeLeafs(root.right)
		removedLeafs = append(removedLeafs, rightLeafs...)
	}

	return root, removedLeafs
}

func moveRobot2(idx IntPair, direction IntPair, segment *Node, mapOfFactory [][]byte) IntPair {
	var leafes []*Node
	for segment != nil || leafes != nil {

		segment, leafes = removeLeafs(segment)
		for _, leaf := range leafes {
			if !leaf.moveable {
				return idx
			}
		}
		for _, leaf := range leafes {
			slices.Reverse(leaf.content)

			prev := direction
			for _, position := range leaf.content {
				prev = position.Sub(direction)
				mapOfFactory[position.Second][position.First] = mapOfFactory[prev.Second][prev.First]
			}
			if len(leaf.content) != 0 {
				mapOfFactory[prev.Second][prev.First] = '.'
			}

		}
	}
	return idx.Add(direction)
}

func gpsLocation(packages []IntPair) int {
	acc := 0
	for _, pac := range packages {
		acc += (100 * pac.Second) + pac.First
	}
	return acc
}

func makeBigMap(mapOfFactory [][]byte) [][]byte {
	bigMap := make([][]byte, len(mapOfFactory))

	for i, line := range mapOfFactory {
		preallocatedSize := len(line) * 2 // Each character doubles in size
		bigMap[i] = make([]byte, 0, preallocatedSize)
		for _, char := range line {
			switch char {
			case WALL:
				bigMap[i] = append(bigMap[i], '#', '#')
			case ROBOT:
				bigMap[i] = append(bigMap[i], '@', '.')
			case EMPTY:
				bigMap[i] = append(bigMap[i], '.', '.')
			case PACKAGE:
				bigMap[i] = append(bigMap[i], '[', ']')
			}
		}
	}
	return bigMap
}

func main() {
	content, err := os.ReadFile("input15_2.txt")
	if err != nil {
		log.Fatal(err)
	}
	results := strings.Split(string(content), "\n\n")

	mapOfFactoryString := strings.Split(results[0], "\n")
	mapOfFactory := make([][]byte, len(mapOfFactoryString))

	for i, s := range mapOfFactoryString {
		mapOfFactory[i] = []byte(s)
	}

	bigMap := makeBigMap(mapOfFactory)
	directions := []byte(results[1])
	idx, found := findCharIndex(mapOfFactory, '@')
	if !found {
		log.Fatal("Robot not found")
	}
	for _, direction := range directions {
		if !(direction == '\n') {
			segment := findSegment(direction, idx, mapOfFactory)
			idx = moveRobot(idx, segment, mapOfFactory)
		}
	}
	packages := GPSLocation(mapOfFactory, 'O')

	idx, found = findCharIndex(bigMap, '@')

	idx, found = findCharIndex(bigMap, '@')
	if !found {
		log.Fatal("Robot not found")
	}
	for _, direction := range directions {
		if !(direction == '\n') {

			segment := findSegment2(direction, idx, bigMap)
			idx = moveRobot2(idx, dirMap[direction], &segment, bigMap)

			for _, rows := range bigMap {
				fmt.Println(string(rows))
			}
		}
	}

	fmt.Println(packages)

	packages = GPSLocation(bigMap, '[')

	fmt.Println(packages)
}
