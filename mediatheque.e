class MEDIATHEQUE

creation{ANY}
	make

feature{}
	lst_user: ARRAY[UTILISATEUR] -- liste des utilisateurs
  	lst_media: ARRAY[MEDIA] -- liste des medias
 -- 	lst_acteurs: ARRAY[ACTEUR] --liste des acteurs
 -- 	lst_realisateurs: ARRAY[REALISATEUR] --liste des réalisateurs
  	lst_auteurs: ARRAY[AUTEUR] -- liste des auteurs

feature{ANY}
	make is
		do
			create lst_user.with_capacity(1, 0)
			create lst_media.with_capacity(1,0)
			create lst_auteurs.with_capacity(1,0)
			remplir_lst_user
			afficher_tableau_user
			remplir_lst_media
			afficher_tableau_media
			remplir_lst_realisateur_acteurs_auteurs
			afficher_tableau_auteurs
		end
	
	remplir_lst_user is
		local
			ligne: STRING -- ligne du fichier utilisateur
			fichier: TEXT_FILE_READ -- Fichier utilisateur ouvert en lecture
			i, index_start, index_end: INTEGER
			nom, prenom, id, admin: STRING -- Attributs utilisateur
			user: UTILISATEUR
			ligne_tab : ARRAY[STRING]
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			nom := ""
			prenom := ""
			id := ""
			admin := ""			
			
			-- Création et ouverture du fichier
			create fichier.make
			fichier.connect_to("utilisateurs.txt")
			
			-- lecture du fichier
			from 
			until fichier.end_of_input 
			loop					
				-- Creation de l'utilisateur
				create user.make
				-- Initialisation du contenant dans chaque case, le texte 
				-- contenu entre les points virgules de "ligne"
				create ligne_tab.with_capacity(1,0)

				ligne := ""
				index_end:= 1
				index_start:=1
				
				-- Lecture d'une ligne
				fichier.read_line_in(ligne)
				
				if ligne.count > 0 then
					
					-- parcours de la ligne, séparation au niveau des 
					-- points virgules et remplissage du tableau
					from  
					until index_end = 0
					loop
						index_end := ligne.index_of(';',index_start)
						if index_end > 0 then
							ligne_tab.add_last(ligne.substring(index_start, index_end-1))
							index_start := index_end+1
						else
							if index_end = 0 then
								ligne_tab.add_last(ligne.substring(index_start, ligne.count))
							end
						end
					end

					--parcours du tableau contenant la ligne fractionnée
					from i :=0
					until i = ligne_tab.count
					loop
						-- si la case correspond au nom, attribuer le nom à l'utilisateur
						if ligne_tab.item(i).has_substring("Nom") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							io.put_string("nom: "+user.get_nom+"%N")
						end

						-- si la case correspond au prénom, attribuer le 
						-- prénom à l'utilisateur
						if ligne_tab.item(i).has_substring("Prenom") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end

						-- si la case correspond à l'identifiant, attribuer 
						-- l'identifiant à l'utilisateur
						if ligne_tab.item(i).has_substring("Identifiant") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_identifiant(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end

						-- si la case indique que l'utilisateur est un 
						-- administrateur, l'attribut admin de l'utilisateur est mis à vrai
						if ligne_tab.item(i).has_substring("Admin") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							admin.copy(ligne_tab.item(i).substring(index_start+1, index_end-1))
							if admin.is_equal("OUI") then
								user.set_admin(True)
							else
								user.set_admin(False)
							end
						end
						i := i + 1
					end
					


					-- Ajout de l'utilisateur dans le tableau
					lst_user.add_last(user)
				end
							
			end
		end
		
	remplir_lst_media is
		local
			ligne: STRING -- ligne du fichier utilisateur
			fichier: TEXT_FILE_READ -- Fichier media ouvert en lecture
			i, index_start, index_end: INTEGER
			titre: STRING 
			livre: LIVRE
			dvd: DVD
			ligne_tab : ARRAY[STRING]
			is_livre: BOOLEAN
			auteur: AUTEUR
			realisateur: REALISATEUR
			acteur: ACTEUR
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""	
			is_livre := False	
			
			-- Création et ouverture du fichier
			create fichier.make
			fichier.connect_to("medias.txt")
			
			-- lecture du fichier
			from 
			until fichier.end_of_input 
			loop	
				-- Initialisation du contenant dans chaque case, le texte 
				-- contenu entre les points virgules de "ligne"
				create ligne_tab.with_capacity(1,0)

				ligne := ""
				index_end:= 1
				index_start:=1
				
				-- Lecture d'une ligne
				fichier.read_line_in(ligne)
				
				if ligne.count > 0 then
					
					-- parcours de la ligne, séparation au niveau des 
					-- points virgules et remplissage du tableau
					from  
					until index_end = 0
					loop
						index_end := ligne.index_of(';',index_start)
						if index_end > 0 then
							ligne_tab.add_last(ligne.substring(index_start, index_end-1))
							index_start := index_end+1
						else
							if index_end = 0 then
								ligne_tab.add_last(ligne.substring(index_start, ligne.count))
							end
						end
					end

					--parcours du tableau contenant la ligne fractionnée
					from i :=0
					until i = ligne_tab.count
					loop
						-- si la case correspond au type livre, créer un livre
						if ligne_tab.item(i).has_substring("Livre") then
							is_livre := True
							create livre.make
							livre.set_type("LIVRE")
						end
						
						-- si la case correspond au type dvd, créer un dvd
						if ligne_tab.item(i).has_substring("DVD") then
							is_livre := False
							create dvd.make
							dvd.set_type("DVD")
						end
						

						-- si la case correspond au titre, attribuer le 
						-- titre au media
						if ligne_tab.item(i).has_substring("Titre") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							if is_livre then
								livre.set_titre(ligne_tab.item(i).substring(index_start+1, index_end-1))
							else
								dvd.set_titre(ligne_tab.item(i).substring(index_start+1, index_end-1))
							end
						end

						-- si la case correspond à nombre d'exemplaire, attribuer 
						-- le nombre d'exemplaires au média
						if ligne_tab.item(i).has_substring("Nombre") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							if is_livre then
								livre.set_nombre_exemplaires((ligne_tab.item(i).substring(index_start+1, index_end-1)).to_integer)
							else
								dvd.set_nombre_exemplaires((ligne_tab.item(i).substring(index_start+1, index_end-1)).to_integer)
							end
						end

						--si la case indique un auteur, on assigne l'auteur au livre
						if ligne_tab.item(i).has_substring("Auteur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create auteur.make
							auteur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							livre.set_auteur(auteur)
							
						end
						
						--si la case indique un acteur, on ajoute l'acteur à la liste
						if ligne_tab.item(i).has_substring("Acteur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create acteur.make
							acteur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							dvd.ajouter_acteur(acteur)
						end
						
						--si la case indique un réalisateur, on ajoute le réalisateur à la liste
						if ligne_tab.item(i).has_substring("Realisateur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create realisateur.make
							realisateur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							dvd.ajouter_realisateur(realisateur)
						end
						i := i + 1
					end
					


					-- Ajout du média dans le tableau
					if is_livre then
						lst_media.add_last(livre)
					else 
						lst_media.add_last(dvd)
					end					
				end
							
			end
		end

	afficher_tableau_user is
		local
			i :INTEGER
		do
			io.put_string("affichage des utilisateurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_user.count
			loop
				io.put_string(lst_user.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_media is
		local
			i :INTEGER
		do
			io.put_string("affichage des médias")
			io.put_string("%N")
			from i:= 0
			until i = lst_media.count
			loop
				io.put_string(lst_media.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_auteurs is
		local
			i :INTEGER
		do
			io.put_string("affichage des auteurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_auteurs.count
			loop
				io.put_string(lst_auteurs.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	remplir_lst_realisateur_acteurs_auteurs is
		local
			i,j: INTEGER
			media: MEDIA
			livre : LIVRE
			dvd : DVD
			trouver: BOOLEAN
		do
			from i:= 0
			until i = lst_media.count
			loop
				media := lst_media.item(i)
				if media.get_type.is_equal("LIVRE") then
					create livre.make
					livre.make_from_media(media)
					trouver:= False
					from j:= 0
					until j = lst_auteurs.count
					loop
						if lst_auteurs.item(j).get_nom = livre.get_auteur.get_nom then
							trouver := True
						end
						j := j+1
					end
					if not trouver then
						lst_auteurs.add_last(livre.get_auteur)
					end
				end
				i := i+1
			end
		end
					


end
















