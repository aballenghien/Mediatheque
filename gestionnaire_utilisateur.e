class GESTIONNAIRE_UTILISATEUR

creation{ANY}
	make

feature{}
	lst_users: ARRAY[UTILISATEUR] -- liste des utilisateurs

feature{ANY}
	make is
	
		do
			create lst_users.with_capacity(1, 0)
		end
		
	--récupère tous les utilisateurs dans le fichier
	remplir_lst_users is
		local
			fichier: TEXT_FILE_READ -- Fichier utilisateur ouvert en lecture
			fichier2: TEXT_FILE_READ -- fichier qui nous servira pour la suite
		do	
			-- Création et ouverture du fichier utilisateur.txt
			create fichier.make
			fichier.connect_to("utilisateurs.txt")
			-- lecture du fichier
			analyser_fichier(fichier)			
			fichier.disconnect

			-- Création et ouverture du fichier utilisateur2.txt
			create fichier2.make
			fichier2.connect_to("utilisateurs2.txt")
			if fichier2.is_connected then			
				-- lecture du fichier
				analyser_fichier(fichier2)
				fichier2.disconnect
			end
		end

	analyser_fichier (fichier: TEXT_FILE_READ) is
		local
			ligne: STRING -- ligne du fichier utilisateur
			i, index_start, index_end: INTEGER
			nom, prenom, id, admin: STRING -- Attributs d'utilisateur
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

			-- lecture du fichier et analyse des lignes
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
					lst_users.add_last(user)
				end		
			end
		end
	
		
	ajouter_utilisateur is
		local
			nom, prenom, identifiant, admin, ligne, essai : STRING
			admin_ok, id_ok : BOOLEAN
			fichier : TEXT_FILE_WRITE
			utilisateur : UTILISATEUR
			i, nb_essai: INTEGER
			correct : BOOLEAN
		do
			nom := ""
			prenom := ""
			identifiant := ""
			admin := ""
			ligne := ""
			essai := ""
			admin_ok := False
			id_ok := False
			
			
			io.put_string("*** Ajouter un nouvel utilisateur ***")
			io.put_string("%N")

			from nb_essai := 0
			until id_ok or nb_essai = 3
			loop
				id_ok := True
				io.put_string("Identifiant de l'utilisateur ? ")
				io.flush
				io.read_line
				identifiant.copy(io.last_string)
			
				from i:= 0
				until i = lst_users.count
				loop
					if lst_users.item(i).get_identifiant.is_equal(identifiant) then
						id_ok := False
					end
					i := i+1
				end
				
				if not id_ok then
					correct := False
					from
					until correct
					loop
						io.put_string("Voulez-vous réessayer ? (O/N)")
						io.flush
						io.read_line
						essai.copy(io.last_string)
						if essai.is_equal("N") then
							nb_essai := 3
							correct := True
						else
							if essai.is_equal("O") then
								nb_essai := nb_essai + 1
								correct := True
							else
								io.put_string("Veuillez taper O pour Oui ou N %
                                      %pour Non")
								io.put_string("%N")
							end
						end
					end
				end
			end
			
			if id_ok = True then
				io.put_string("Nom de l'utilisateur ? ")
				io.flush
				io.read_line
				nom.copy(io.last_string)
				io.put_string("Prénom de l'utilisateur ? ")
				io.flush
				io.read_line
				prenom.copy(io.last_string)

				from 
				until admin_ok
				loop
					io.put_string("L'utilisateur sera t'il un administrateur ? (O/N)")
					io.put_string("%N")
					io.flush
					io.read_line
					admin.copy(io.last_string)
					if admin.is_equal("O") or admin.is_equal("N") then
						admin_ok := True
					else
						admin_ok := False
					end
				end
			
				ligne.append("Nom<"+nom+"> ; Prenom<"+prenom+"> ; Identifiant<"+identifiant+">")
				if admin.is_equal("O") then
					ligne.append(" ; Admin<OUI>")
				end
			
				create fichier.make
				fichier.connect_for_appending_to("utilisateurs2.txt")
				fichier.put_line(ligne)
				fichier.disconnect
			
				create utilisateur.make
				utilisateur.set_nom(nom)
				utilisateur.set_prenom(prenom)
				utilisateur.set_identifiant(identifiant)
			
				if admin.is_equal("O") then
					utilisateur.set_admin(True)
				end
				lst_users.add_last(utilisateur)
			
				io.put_string("Nouvel utilisateur ajouté : ")
				io.put_string(ligne)
			else
				io.put_string("L'identifiant est déjà utilisé, impossible d'ajouter l'utilisateur.")
			end
		end
		
		-- Fonction recherchant un utilisateur dans la liste des utilisateurs	
	rechercher_utilisateur(identifiant : STRING) : UTILISATEUR is
		local
			i : INTEGER
		do
			Result := Void
			-- on parcourt la liste des utilisateurs
			from i := 0
			until i = lst_users.count
			loop
				-- test sur l'identifiant
				if lst_users.item(i).get_identifiant.is_equal(identifiant) then
					-- si on le trouve, on renvoie l'utilisateur
					Result := lst_users.item(i)
				end
				i := i + 1
			end
		end
		
		get_lst_users : ARRAY[UTILISATEUR] is
			do
				Result := lst_users
			end
end
