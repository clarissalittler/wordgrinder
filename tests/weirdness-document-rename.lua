--!nonstrict
loadfile("tests/testsuite.lua")()

AssertEquals(currentDocument.name, "main")
documentSet:renameDocument("main", "new")

AssertEquals(currentDocument.name, "new")
AssertTableEquals({["new"]= currentDocument}, documentSet._documentIndex)
