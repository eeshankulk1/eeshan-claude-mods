-- Clickable Copy: opens the clickable-copy:// links the clickable mod draws
-- under code blocks and copies the text behind them (copy.sh does the work).

on open location theURL
	try
		set helper to quoted form of (POSIX path of (path to resource "copy.sh"))
		set firstLine to do shell script helper & " " & quoted form of theURL
		display notification firstLine with title "Copied"
	on error errText
		display notification errText with title "Clickable Copy"
	end try
end open location

-- Opened by hand it has nothing to do.
on run
end run
