class GESTIONNAIRE_UTILISATEUR

creation{ANY}
	make

feature{}
	mediatheque : MEDIATHEQUE

feature{ANY}
	make (m : MEDIATHEQUE) is
	
		do
			mediatheque := m
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
					mediatheque.get_lst_users.add_last(user)
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
			
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*     AJOUTER UTILISATEUR      *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")

			from nb_essai := 0
			until id_ok or nb_essai = 3
			loop
				id_ok := True
				io.put_string("Identifiant de l'utilisateur ? ")
				io.flush
				io.read_line
				if nb_essai = 0 then
					io.read_line
				end
				identifiant.copy(io.last_string)
				from i:= 0
				until i = mediatheque.get_lst_users.count
				loop
					if mediatheque.get_lst_users.item(i).get_identifiant.is_equal(identifiant) then
						id_ok := False
					end
					i := i+1
				end
				
				if not id_ok then
					correct := False
					nb_essai := nb_essai + 1
					if nb_essai = 3 then
						correct := True
						io.put_string("Vous avez utilisé vos 3 essais.")
					else 
						from
						until correct
						loop
							io.put_string("L'identifiant existe déjà. Voulez-vous réessayer ? (O/N) ")
							io.flush
							io.read_line
							essai.copy(io.last_string)
							if essai.is_equal("N") then
								nb_essai := 3
								correct := True
							else
								if essai.is_equal("O") then
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
				mediatheque.get_lst_users.add_last(utilisateur)
			
				io.put_string("Nouvel utilisateur ajouté ! ")
				io.put_string("%N")
				io.put_string(utilisateur.to_string)
			end
		end
		
	afficher_info_compte(user : UTILISATEUR) is
		local
			choix : INTEGER
			correct : BOOLEAN
		do
			correct := False
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*  DETAILS COMPTE UTILISATEUR  *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string(user.to_string)
			io.put_string("%N")
			from
			until correct
			loop
				io.put_string("1. Modifier information%N")
				io.put_string("2. Retour%N")
				io.flush
				io.read_integer
				choix := io.last_integer
				if choix = 1 then
					correct := True
					modifier_utilisateur(user, False)
				elseif choix = 2 then
					correct := True
				end
			end			
		end
		
	modifier_un_utilisateur is
		local
			identifiant, choix : STRING
			user : UTILISATEUR
			id_ok, correct, premier : BOOLEAN
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*     MODIFIER UTILISATEUR     *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			identifiant := ""	
			choix := ""		
			premier := True
			id_ok := False
			from
			until id_ok
			loop
				io.put_string("Identifiant de l'utilisateur à modifier ?%N")
				io.flush
				if premier then
					io.read_line
					premier := False
				end
				io.read_line
				identifiant.copy(io.last_string)
				user := rechercher_utilisateur(identifiant)
				if user /= Void then
					id_ok := True
					modifier_utilisateur(user, True)	
				else
					correct := False
					from
					until correct
					loop
						io.put_string("L'identifiant saisi ne correspond à aucun utilisateur. Réesayer ? (O/N)%N")
						io.flush
						io.read_line
						choix.copy(io.last_string)
						if choix.is_equal("O") then
							correct := True
							id_ok := False
						elseif choix.is_equal("N") then
							correct := True
							id_ok := True
						else
							io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
						end
					end
				end
			end							
		end
	
	modifier_utilisateur(user : UTILISATEUR; modifier : BOOLEAN) is
		local
			choix : STRING
			correct : BOOLEAN
			mod : BOOLEAN
		do
			choix := ""
			mod := modifier
			if not modifier then
				io.put_string("%N")
				io.put_string("*********************************")
				io.put_string("%N")
				io.put_string("*  MODIFIER COMPTE UTILISATEUR  *")
				io.put_string("%N")
				io.put_string("*********************************")
				io.put_string("%N")
			end
			io.put_string("Nom actuel : "+user.get_nom+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier nom ? (O/N) %N")
				io.flush
				if not mod then
					mod:= True
					io.read_line
				end
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					io.put_string("Nouveau nom : ")
					io.flush
					io.read_line
					user.set_nom(io.last_string)
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			
			io.put_string("Prénom actuel : "+user.get_prenom+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier prénom ? (O/N) %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					io.put_string("Nouveau prénom : ")
					io.flush
					io.read_line
					user.set_prenom(io.last_string)
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			
			if mediatheque.get_utilisateur_connecte.is_admin then
				correct := False
				if user.is_admin then
					from
					until correct
					loop
						io.put_string("L'utilisateur est administrateur. %N")
						io.put_string("Changer son statut ? (O/N) (il deviendra non administrateur) %N")
						io.flush
						io.read_line
						choix.copy(io.last_string)
						if choix.is_equal("O") then
							user.set_admin(False)
							correct := True
						elseif choix.is_equal("N") then
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
						end
					end
				else
					from
					until correct
					loop
						io.put_string("L'utilisateur n'est pas administrateur. %N")
						io.put_string("Changer son statut ? (O/N) (il deviendra administrateur) %N")
						io.flush
						io.read_line
						choix.copy(io.last_string)
						if choix.is_equal("O") then
							user.set_admin(True)
							correct := True
						elseif choix.is_equal("N") then
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
						end
					end
				end
			end
		end
		
	rechercher is
		local
			identifiant, choix : STRING
			user : UTILISATEUR
			id_ok, correct, premier : BOOLEAN
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*    RECHERCHER UTILISATEUR    *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			identifiant := ""	
			choix := ""		
			premier := True
			id_ok := False
			from
			until id_ok
			loop
				io.put_string("Identifiant de l'utilisateur à rechercher ?%N")
				io.flush
				if premier then
					io.read_line
					premier := False
				end
				io.read_line
				identifiant.copy(io.last_string)
				user := rechercher_utilisateur(identifiant)
				if user /= Void then
					id_ok := True
					afficher_info_compte(user)
				else
					correct := False
					from
					until correct
					loop
						io.put_string("L'identifiant saisi ne correspond à aucun utilisateur. Réesayer ? (O/N)%N")
						io.flush
						io.read_line
						choix.copy(io.last_string)
						if choix.is_equal("O") then
							correct := True
							id_ok := False
						elseif choix.is_equal("N") then
							correct := True
							id_ok := True
						else
							io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
						end
					end
				end
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
			until i = mediatheque.get_lst_users.count
			loop
				-- test sur l'identifiant
				if mediatheque.get_lst_users.item(i).get_identifiant.is_equal(identifiant) then
					-- si on le trouve, on renvoie l'utilisateur
					Result := mediatheque.get_lst_users.item(i)
				end
				i := i + 1
			end
		end
end
