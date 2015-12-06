class ACTEUR inherit
	PERSONNE
	rename make as make_personne
	redefine to_string
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
	ajouter_film (un_film: DVD) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			from i:=0
			until i = lst_films.count
			loop
				if lst_films.item(i).get_titre.is_equal(un_film.get_titre) then
					trouver := True
				end
				i := i+1
			end
			if not trouver then
				lst_films.add_last(un_film)
			end
		end
		
	to_string : STRING is
		local
			rst: STRING
			i : INTEGER
		do
			rst := ""
			rst.append("ACTEUR:{nom: "+nom+", prenom:"+prenom+", lst_films:")
			from i:=0
			until i = lst_films.count
			loop
				rst.append(lst_films.item(i).get_titre+" ,")
				i:= i+1
			end
			rst.append("}")
			Result := rst
		end
	
	get_lst_films : ARRAY[DVD] is
		do
			Result := lst_films
		end

end
