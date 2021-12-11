//go:build mage
// +build mage

package main

import (
	"fmt"
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Build the container image.
func BuildContainer() error {
	fmt.Println("Building Docker image...")
	return sh.RunV("docker", "build", "-t", "dirien/simple-go", ".")
}

// Push the container image to Docker Hub.
func PushContainer() error {
	mg.Deps(BuildContainer)
	fmt.Println("Pushing Docker image...")
	return sh.RunV("docker", "push", "dirien/simple-go")
}

// Build the container image and push it to Docker Hub.
func Build() {
	mg.Deps(BuildContainer, PushContainer)
}

// Default target.
var Default = Build
