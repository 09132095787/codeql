package main

import (
	"fmt"
	"log"
	"net/http"
	"regexp"

	ldap "gopkg.in/ldap.v2"
)

func bad(w http.ResponseWriter, req *http.Request) (interface{}, error) {
	ldapServer := "ldap.example.com"
	ldapPort := 389
	bindDN := "cn=admin,dc=example,dc=com"
	bindPassword := req.URL.Query()["password"][0]

	// Connect to the LDAP server
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", ldapServer, ldapPort))
	if err != nil {
		log.Fatalf("Failed to connect to LDAP server: %v", err)
	}
	defer l.Close()

	// BAD: user input is not sanetized
	err = l.Bind(bindDN, bindPassword)
	if err != nil {
		log.Fatalf("LDAP bind failed: %v", err)
	}
}

func good1(w http.ResponseWriter, req *http.Request) (interface{}, error) {
	ldapServer := "ldap.example.com"
	ldapPort := 389
	bindDN := "cn=admin,dc=example,dc=com"
	bindPassword := req.URL.Query()["password"][0]

	// Connect to the LDAP server
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", ldapServer, ldapPort))
	if err != nil {
		log.Fatalf("Failed to connect to LDAP server: %v", err)
	}
	defer l.Close()

	hasEmptyInput, _ := regexp.MatchString("^\\s*$", bindPassword)

	// GOOD : bindPassword is not empty
	if !hasEmptyInput {
		l.Bind(bindDN, bindPassword)
	}
}

func good2(w http.ResponseWriter, req *http.Request) (interface{}, error) {
	ldapServer := "ldap.example.com"
	ldapPort := 389
	bindDN := "cn=admin,dc=example,dc=com"
	bindPassword := req.URL.Query()["password"][0]

	// Connect to the LDAP server
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", ldapServer, ldapPort))
	if err != nil {
		log.Fatalf("Failed to connect to LDAP server: %v", err)
	}
	defer l.Close()

	// GOOD : bindPassword is not empty
	if bindPassword != "" {
		l.Bind(bindDN, bindPassword)
	}
}

func bad2(req *http.Request) {
	// LDAP server details
	ldapServer := "ldap.example.com"
	ldapPort := 389
	bindDN := "cn=admin,dc=example,dc=com"
	// BAD : empty password
	bindPassword := ""

	// Connect to the LDAP server
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", ldapServer, ldapPort))
	if err != nil {
		log.Fatalf("Failed to connect to LDAP server: %v", err)
	}
	defer l.Close()

	// BAD : bindPassword is empty
	err = l.Bind(bindDN, bindPassword)
	if err != nil {
		log.Fatalf("LDAP bind failed: %v", err)
	}
}

func main() {
	bad(nil, nil)
	good1(nil, nil)
	good2(nil, nil)
	bad2(nil)
}
