class AUTEUR inherit
	PERSONNE
	rename make as make_personne
	end

creation{ANY}
	make

feature{}
	lst_livres: ARRAY[LIVRE]

feature {ANY}
	make is
		do
			make_personne
			create lst_livres.with_capacity(1,0)
		end

end
