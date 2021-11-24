#!/usr/bin/fish
if test (cat ".signature.sig") = (fish generate.fish)
	exit 0
end

exit 1
