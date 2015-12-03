class AUTEUR inherit
	PERSONNE
	rename make as make_personne
	redefine to_string
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
	
	ajouter_livre (un_livre: LIVRE) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			from i:=0
			until i = lst_livres.count
			loop
				if lst_livres.item(i).get_titre.is_equal(un_livre.get_titre) then
					trouver := True
				end
				i := i+1
			end
			if not trouver then
				lst_livres.add_last(un_livre)
			end
		end
	to_string : STRING is
		local
			rst: STRING
			i : INTEGER
		do
			rst := ""
			rst.append("AUTEUR:{nom: "+nom+", prenom:"+prenom+", lst_livres:")
			from i:=0
			until i = lst_livres.count
			loop
				rst.append(lst_livres.item(i).get_titre+" ,")
				i:= i+1
			end
			rst.append("}")
			Result := rst
		end
			

end
