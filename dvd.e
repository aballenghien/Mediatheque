class DVD inherit
	MEDIA

creation{ANY}
	make

feature{}
	annee: INTEGER

feature {ANY}
	set_annee(a: INTEGER) is
		do
			annee := a
		end
	
	get_annee is
		do
			Result:= annee
		end

end
