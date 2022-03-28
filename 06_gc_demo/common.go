package _6_gc_demo

import "time"

const SamplesCount = 512

type HugeStructure struct {
	ID int64 `json:"id"`

	Description string    `json:"description"`
	FistName    string    `json:"fist_name"`
	LastName    string    `json:"last_name"`
	BirthDay    time.Time `json:"birth_day"`
	Weight      float64   `json:"weight"`
	Height      float64   `json:"height"`

	Block1 BlockType `json:"block_1"`
	Block2 BlockType `json:"block_2"`
	Block3 BlockType `json:"block_3"`
	Block4 BlockType `json:"block_4"`
	Block5 BlockType `json:"block_5"`
	Block6 BlockType `json:"block_6"`
	Block7 BlockType `json:"block_7"`
	Block8 BlockType `json:"block_8"`
}

const BlockSize = 4096

type BlockType []byte

const Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
