function multi-dot() {
	local dots=$LBUFFER[-2,-1]
	if [[ $dots == ".." ]]; then
		LBUFFER=$LBUFFER[1,-3]'../.'
	fi
	zle self-insert
}
zle -N multi-dot
