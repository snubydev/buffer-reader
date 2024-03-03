package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"time"
)

func stdRead() {
	file, err := os.Open("large-file.json")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	lineCount := 0
	byteCount := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lineCount += 1
		byteCount += len(scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}
	// fmt.Printf("%d lines, %d bytes\n", lineCount, byteCount)
}

func do() int64 {
	start := time.Now().UnixNano()
	stdRead()
	finish := time.Now().UnixNano()
	return finish - start
}

func main() {
	timer := time.NewTicker(time.Second * 3)
	var acc int64 = 0
	n := 10_000_000
	i := 0

loop:
	for {
		select {
		case <-timer.C:
			break loop
		default:
			i += 1
			if i > n {
				break loop
			}
			acc += do()
		}
	}

	fmt.Printf("%d iterations %fms per iteration\n", i, float64(acc/int64(i))/1000/1000)
}
