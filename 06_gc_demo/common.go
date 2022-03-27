package _6_gc_demo

import "time"

const SamplesCount = 1024

type HugeStructure struct {
	ID int64 `json:"id"`

	Description string    `json:"description"`
	FistName    string    `json:"fist_name"`
	LastName    string    `json:"last_name"`
	BirthDay    time.Time `json:"birth_day"`
	Weight      float64   `json:"weight"`
	Height      float64   `json:"height"`

	Block1  [4096]byte `json:"block_1"`
	Block2  [4096]byte `json:"block_2"`
	Block3  [4096]byte `json:"block_3"`
	Block4  [4096]byte `json:"block_4"`
	Block5  [4096]byte `json:"block_5"`
	Block6  [4096]byte `json:"block_6"`
	Block7  [4096]byte `json:"block_7"`
	Block8  [4096]byte `json:"block_8"`
	Block9  [4096]byte `json:"block_9"`
	Block10 [4096]byte `json:"block_10"`
	Block11 [4096]byte `json:"block_11"`
	Block12 [4096]byte `json:"block_12"`
	Block13 [4096]byte `json:"block_13"`
	Block14 [4096]byte `json:"block_14"`
	Block15 [4096]byte `json:"block_15"`
	Block16 [4096]byte `json:"block_16"`
}

const Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
