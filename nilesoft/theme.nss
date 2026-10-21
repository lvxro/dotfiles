// Night Balcony — Nilesoft Shell theme
// Copy to "C:\Program Files\Nilesoft Shell\imports\theme.nss"
theme
{
	name="modern"
	dark=true
	font
	{
		name="Rounded Mplus 1c"
		size=13
		weight=5
	}
	background
	{
		color=#0E1424
		opacity=88
		effect=[3, #0E1424, 70]
	}
	border
	{
		enabled=true
		size=1
		color=#26304F
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
			normal=#DFE6FB
			normal.disabled=#5A6A99
			select=#6FA4FF
			select.disabled=#5A6A99
		}
		back
		{
			select=#2A3760
			select.disabled=#141C30
		}
		padding = [8, 8, 4, 4]
		margin = [4, 2]
	}
	separator
	{
		color=#26304F
		opacity=100
		margin = [10, 6]
	}
	symbol
	{
		normal=#A3B4E0
		select=#6FA4FF
		normal.disabled=#5A6A99
		select.disabled=#5A6A99
		checkmark
		{
			normal=#9B82FF
			select=#9B82FF
		}
	}
	image
	{
		color=[#6FA4FF, #A3B4E0, #9B82FF]
		align=2
	}
}
