// Red Balloon — Nilesoft Shell theme
// Copy to "C:\Program Files\Nilesoft Shell\imports\theme.nss"
theme
{
	name="modern"
	dark=true
	font
	{
		name="Zen Kaku Gothic New"
		size=13
		weight=5
	}
	background
	{
		color=#08202B
		opacity=88
		effect=[3, #08202B, 70]
	}
	border
	{
		enabled=true
		size=1
		color=#1F4B58
		radius=8
	}
	shadow
	{
		enabled=true
		size=8
		color=#000000
		opacity=40
		offset=2
	}
	item
	{
		radius=3
		text
		{
			normal=#F4E6DA
			normal.disabled=#5E8285
			select=#FCCCA8
			select.disabled=#5E8285
		}
		back
		{
			select=#1D5866
			select.disabled=#0F3340
		}
		padding = [8, 8, 4, 4]
		margin = [4, 2]
	}
	separator
	{
		color=#1F4B58
		opacity=100
		margin = [10, 6]
	}
	symbol
	{
		normal=#A9CBC1
		select=#FCCCA8
		normal.disabled=#5E8285
		select.disabled=#5E8285
		checkmark
		{
			normal=#FF6B6B
			select=#FF6B6B
		}
	}
	image
	{
		color=[#FCCCA8, #A9CBC1, #FF6B6B]
		align=2
	}
}
