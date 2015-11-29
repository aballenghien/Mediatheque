class DVD inherit
	MEDIA
	rename make as make_media
	end

creation{ANY}
	make

feature{}
	annee: INTEGER
	lst_acteurs: ARRAY[ACTEUR]
	lst_realisateurs: ARRAY[REALISATEUR]

feature {ANY}
	make is
		do
			make_media
			annee := 0			
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
		end
		
	set_annee(a: INTEGER) is
		do
			annee := a
		end
	
	get_annee : INTEGER is
		do
			Result:= annee
		end
	
	ajouter_acteur (a: ACTEUR) is
		do
			lst_acteurs.add_last(a)
		end
		
	ajouter_realisateur (r: REALISATEUR) is
		do
			lst_realisateurs.add_last(r)
		end

end
