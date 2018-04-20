package letsdebug

import (
	"fmt"
)

// PriorityLevel represents the priority of a reported problem
type PriorityLevel string

// Problem represents an issue found by one of the checkers in this package.
// Explanation is a human-readable explanation of the issue.
// Detail is usually the underlying machine error.
type Problem struct {
	Name        string
	Explanation string
	Detail      string
	Priority    PriorityLevel
}

const (
	PriorityFatal   PriorityLevel = "PriorityFatal" // Represents a fatal error which will stop any further checks
	PriorityError   PriorityLevel = "Error"
	PriorityWarning PriorityLevel = "Warning"
	PriorityInfo    PriorityLevel = "Info"
)

func (p Problem) String() string {
	return fmt.Sprintf("[%s] %s: %s", p.Name, p.Explanation, p.Detail)
}

func internalProblem(message string, level PriorityLevel) Problem {
	return Problem{
		Name:        "InternalProblem",
		Explanation: fmt.Sprintf("An internal error occured while checking the domain"),
		Detail:      message,
		Priority:    level,
	}
}

func dnsLookupFailed(name, rrType string, err error) Problem {
	return Problem{
		Name:        "DNSLookupFailed",
		Explanation: fmt.Sprintf(`A fatal issue occured during the DNS lookup process for %s/%s.`, name, rrType),
		Detail:      err.Error(),
		Priority:    PriorityFatal,
	}
}