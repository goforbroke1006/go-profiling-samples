package _6_gc_demo

import (
	"fmt"
	"testing"
	"unsafe"
)

func TestNothing(t *testing.T) {
	fmt.Println(unsafe.Sizeof(HugeStructure{}))
}
