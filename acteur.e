class ACTEUR inherit
	PERSONNE
	rename make as make_personne
	end

creation{ANY}
	make

feature{}		
	lst_films: ARRAY[DVD]

feature {ANY}
	make is
		do
			make_personne
			create lst_films.with_capacity(1,0)
		end

end
