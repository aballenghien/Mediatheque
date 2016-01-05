class GESTIONNAIRE_EMPRUNT_RESERVATION

creation{ANY}
	make

feature{}
  	mediatheque : MEDIATHEQUE

feature{ANY}
	make (m : MEDIATHEQUE) is
		do
			mediatheque := m
		end
	
	-- rempli la liste des réservations pour chacun des médias et chacun des utilisateurs
	remplir_lst_reservations is
		local
			index_start : INTEGER
			index_end : INTEGER
			titre : STRING
			identifiant : STRING -- identifiant de l'utilisateur
			fichier : TEXT_FILE_READ -- fichier contenant les réservations
			ligne_tab : ARRAY[STRING]
			ligne : STRING
			i, j : INTEGER
			index_user : INTEGER -- index de l'utilisateur dans la liste
			index_livre : INTEGER -- index du livre dans la liste
			index_dvd : INTEGER -- index du dvd dans la liste
			user : UTILISATEUR -- utilisateur concerné par la réservation
			dvd: DVD -- dvd concerné par la réservation
			livre: LIVRE -- livre concerné par la réservation
			une_resa : RESERVATION
			priorite : INTEGER -- priorié sur la réservation de l'ouvrage
			resa_ajouter : BOOLEAN
			numero : STRING -- numéro identifiant la réservation
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""
			identifiant := ""
			create fichier.make
			fichier.connect_to("reservations.txt")
			if fichier.is_connected then
		
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
						index_dvd := -1
						index_livre := -1
						index_user := -1
						priorite := 1
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
						from j :=0
						until j = ligne_tab.count
						loop
						
							-- récupération du numéro de la réservation
							if ligne_tab.item(j).has_substring("Numero") then								
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								numero := ligne_tab.item(j).substring(index_start+1, index_end-1)
							end
					
							-- récupération de l'utilisateur correspondant à la réservation
							if ligne_tab.item(j).has_substring("Utilisateur")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								identifiant.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_users.count
								loop
									if identifiant.is_equal(mediatheque.get_lst_users.item(i).get_identifiant) then
										index_user := i 
										user := mediatheque.get_lst_users.item(i)
									end							
									i := i+1
								end													
							end -- end si case utilisateur
						
							-- récupération du dvd correspondant à la réservation
							if ligne_tab.item(j).has_substring("DVD")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_dvd.count
								loop
									if titre.is_equal(mediatheque.get_lst_dvd.item(i).get_titre) then
										index_dvd := i 
										dvd := mediatheque.get_lst_dvd.item(i)
									end							
									i := i+1
								end													
							end -- end DVD
						
							-- récupération du livre correspondant à la réservation
							if ligne_tab.item(j).has_substring("LIVRE")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_livres.count
								loop
									if titre.is_equal(mediatheque.get_lst_livres.item(i).get_titre) then
										index_livre := i 
										livre := mediatheque.get_lst_livres.item(i)
									end							
									i := i+1
								end													
							end -- end livre
							if ligne_tab.item(j).has_substring("Priorite")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								priorite := (ligne_tab.item(j).substring(index_start+1, index_end-1)).to_integer
							end 
							j := j+1
						end -- end loop parcours ligne
						-- création de l'instance de réservation
						create une_resa.make
						une_resa.set_user(user)
						une_resa.set_priorite(priorite)
						une_resa.set_numero(numero)
						if index_dvd > -1 then
						-- ajout de la réservation au dvd de la liste
							une_resa.set_dvd(dvd)
							resa_ajouter := mediatheque.get_lst_dvd.item(index_dvd).ajouter_reservation(une_resa)
						else
						-- ajout de la réservation au livre de la liste
							if index_livre > -1 then
								une_resa.set_livre(livre)
								resa_ajouter := mediatheque.get_lst_livres.item(index_livre).ajouter_reservation(une_resa)
							end
						end
						-- ajout de la réservation à un utilisateur de la liste
						if index_user > -1 then
							resa_ajouter := mediatheque.get_lst_users.item(index_user).ajouter_reservation(une_resa)
						end
						
						-- ajout de la réservation à la liste des réservations de l'utilisateur connecte
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							resa_ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
			
		end
	
	-- rempli la liste des emprunts de chacun des utilisateurs et de chaun des médias	
	remplir_lst_emprunts is
		local
			index_start : INTEGER
			index_end : INTEGER
			titre : STRING
			identifiant : STRING
			fichier : TEXT_FILE_READ
			ligne_tab : ARRAY[STRING]
			ligne : STRING
			i, j : INTEGER
			index_user : INTEGER
			index_livre : INTEGER
			index_dvd : INTEGER
			user : UTILISATEUR
			dvd: DVD
			livre: LIVRE
			un_emp : EMPRUNT
			emp_ajouter : STRING
			emp_ajouter_media : BOOLEAN
			numero : STRING
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""
			identifiant := ""
			create fichier.make
			fichier.connect_to("emprunts.txt")
			if fichier.is_connected then
		
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
						index_dvd := -1
						index_livre := -1
						index_user := -1
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
						from j := 0
						until j = ligne_tab.count
						loop
							--récupération du numéro de l'emprunt
							if ligne_tab.item(j).has_substring("Numero")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								numero := ligne_tab.item(j).substring(index_start+1, index_end-1)
							end
						
							-- récupération de l'utilisateur correspondant à l'emprunt
							if ligne_tab.item(j).has_substring("Utilisateur")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								identifiant.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_users.count
								loop
									if identifiant.is_equal(mediatheque.get_lst_users.item(i).get_identifiant) then
										index_user := i 
										user := mediatheque.get_lst_users.item(i)
									end							
									i := i+1
								end													
							end -- end si case utilisateur
						
							-- récupération du dvd correspondant à l'emprunt
							if ligne_tab.item(j).has_substring("DVD")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_dvd.count
								loop
									if mediatheque.get_lst_dvd.item(i).get_titre.has_substring(titre) then
										index_dvd := i 
										dvd := mediatheque.get_lst_dvd.item(i)
									end							
									i := i+1
								end													
							end -- end DVD
						 	
						 	--récupération du livre correspondant à l'emprunt
							if ligne_tab.item(j).has_substring("LIVRE")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_livres.count
								loop
									if mediatheque.get_lst_livres.item(i).get_titre.has_substring(titre) then
										index_livre := i 
										livre := mediatheque.get_lst_livres.item(i)
									end							
									i := i+1
								end													
							end -- end livre							
							j := j+1
						end -- end loop parcours ligne
						
						--création de l'emprunt
						create un_emp.make
						un_emp.set_user(user)
						un_emp.set_numero(numero)
						if index_dvd > -1 then
							-- ajout du dvd
							un_emp.set_dvd(dvd)
							emp_ajouter := mediatheque.get_lst_dvd.item(index_dvd).ajouter_emprunt(un_emp)
						else
							--ajout du livre
							un_emp.set_livre(livre)
							emp_ajouter := mediatheque.get_lst_livres.item(index_livre).ajouter_emprunt(un_emp)
						end
						-- ajout à l'utilisateur
						emp_ajouter_media := mediatheque.get_lst_users.item(index_user).ajouter_emprunt(un_emp)
						
						--ajout àl'utilisateur connecte
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							emp_ajouter_media := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emp)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
		end
		
	-- procédure pour que l'utilisateur connecte emprunte un média
	emprunter_un_media(choix_media : INTEGER) is
		local
			livre : LIVRE
			dvd : DVD
			i,j : INTEGER
			is_livre : BOOLEAN
			un_emprunt : EMPRUNT
			une_resa : RESERVATION
			ajouter : BOOLEAN
			ajouter_ds_media : STRING
			correct : BOOLEAN
			reserver : BOOLEAN
			choix : STRING
			fichier_emprunt : TEXT_FILE_WRITE
			fichier_reservation : TEXT_FILE_WRITE
		do
			is_livre := False
			ajouter := False
			
			-- on récupère le média choisi
			from i:= 0
			until i = mediatheque.get_lst_media_choisis.count
			loop
				if i = choix_media then
					if mediatheque.get_lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = mediatheque.get_lst_livres.count
						loop
							if mediatheque.get_lst_livres.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								livre := mediatheque.get_lst_livres.item(j)
								is_livre := True
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = mediatheque.get_lst_dvd.count
						loop
							if mediatheque.get_lst_dvd.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								dvd := mediatheque.get_lst_dvd.item(j)
							end
							j := j+1
						end
					end
				end
				i := i+1
			end
			-- on créer un emprunt dans le cas d'un livre
			reserver := False
			if is_livre then
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_livre(livre)
				un_emprunt.set_numero(generer_numero)
				ajouter_ds_media := livre.ajouter_emprunt(un_emprunt)
				-- ajouter_emprunt retourne NON si le média n'est pas disponible à l'emprunt
				if ajouter_ds_media.is_equal("NON") then
					correct := False
					from
					until correct
					loop
						io.put_string("Ce livre est déjà emprunté, souhaitez vous le réserver ? (O/N) %N")
						io.flush
						io.read_line
						io.read_line
						choix := io.last_string
						if choix.is_equal("O") or choix.is_equal("N") then
							correct := True
							if choix.is_equal("O") then
								reserver := True
							end
						end
					end	
				end	
				--ajouter_emprunt retourneFAIT si l'utilisateur possède déjà le média 
				if ajouter_ds_media.is_equal("FAIT") then
					io.put_string("Vous empruntez déjà ce livre! %N")
					reserver := False
				end	
				
				-- si le média est disponible on ajouter l'emprunt dans la liste de l'utilisateur		
				if ajouter_ds_media.is_equal("OUI") then
					ajouter := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emprunt)
					if not ajouter then
						correct := False
						from
						until correct
						loop
							io.put_string("Vous avez déjà emprunté trois médias, souhaitez vous réserver ce livre? (O/N) %N")
							io.flush
							io.read_line
							io.read_line
							choix := io.last_string
							if choix.is_equal("O") or choix.is_equal("N") then
								correct := True
								if choix.is_equal("O") then
									reserver := True
								end
							end
						end
					end	
				end
				-- si l'emprunt s'est correctement déroulé, on l'inscrit dans le fichier des emprunts
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré !%N")
				end
				
				-- sinon, si l'utilisateur peutet souhaite réserver le média, on réaliser une réservation
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_user(mediatheque.get_utilisateur_connecte)
					une_resa.set_livre(livre)
					une_resa.set_numero(generer_numero)
					ajouter := livre.ajouter_reservation(une_resa)
					if not ajouter then
						io.put_string("La réservation n'a pas pu être effectuée %N")
					end
					if ajouter then
						ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						if not ajouter then
							io.put_string("Vous ne pouvez pas réserver plus de trois médias simultanément %N")
						end
					end		
					-- si la réservation s'est correctement déroulé on l'inscrit dans le fichier réservation			
					if ajouter then
						create fichier_reservation.make
						fichier_reservation.connect_for_appending_to("reservations.txt")
						fichier_reservation.put_line(une_resa.format_enregistrement)
						fichier_reservation.disconnect
						io.put_string("Réservation effectuée ! %N")
					end
				end
			else
				-- réalisation d'un emprunt dans le cas d'un dvd
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_dvd(dvd)
				un_emprunt.set_numero(generer_numero)
				ajouter_ds_media := dvd.ajouter_emprunt(un_emprunt)
				if ajouter_ds_media.is_equal("NON") then
					correct := False
					from
					until correct
					loop
						io.put_string("Ce DVD est déjà emprunté, souhaitez vous le réserver ? (O/N) %N")
						io.flush
						io.read_line
						io.read_line
						choix := io.last_string
						if choix.is_equal("O") or choix.is_equal("N") then
							correct := True
							if choix.is_equal("O") then
								reserver := True
							end
						end
					end	
				end	
				if ajouter_ds_media.is_equal("FAIT") then
					io.put_string("Vous empruntez déjà ce DVD! %N")
					reserver := False
				end
				if ajouter_ds_media.is_equal("OUI") then
					ajouter := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emprunt)
					if not ajouter then
						correct := False
						from
						until correct
						loop
							io.put_string("Vous avez déjà emprunté trois médias, souhaitez vous réserver ce DVD? (O/N) %N")
							io.flush
							io.read_line
							io.read_line
							choix := io.last_string
							if choix.is_equal("O") or choix.is_equal("N") then
								correct := True
								if choix.is_equal("O") then
									reserver := True
								end
							end
						end
					end	
				end
				-- si l'emprunt s'est correctement déroulé, on l'ajouter dans le fichier des emprunts
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré ! %N")
				end
				--sinon, si l'utilisateur peut et souhaite réserver le dvd, on créer une réservation
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_numero(generer_numero)
					une_resa.set_user(mediatheque.get_utilisateur_connecte)
					une_resa.set_dvd(dvd)
					ajouter := dvd.ajouter_reservation(une_resa)
					if not ajouter then
						io.put_string("La réservation n'a pas pu être effectuée. %N")
					end
					if ajouter then
						ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						if not ajouter then
							io.put_string("Vous ne pouvez pas réserver plus de trois médias simultanément. %N")
						end
					end
					-- si la réservation s'est correctement déroulé, on l'ajoute au fichier des réservations
					if ajouter then
						create fichier_reservation.make
						fichier_reservation.connect_for_appending_to("reservations.txt")
						fichier_reservation.put_line(une_resa.format_enregistrement)
						fichier_reservation.disconnect
						io.put_string("Réservation effectuée ! %N")
					end
				end
			end
		end
		
	-- affichage du menu permettant à l'utilisateur de consulter ses emprunts et ses réservations
	gerer_emprunt_reservation is
		local
			continuer : BOOLEAN
			choix_gestion : INTEGER
		do
			continuer := True
			from
			until not continuer
			loop
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("* MENU EMPRUNTS & RESERVATIONS *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("Que souhaiter vous faire? %N")
				io.put_string("1. Consulter mes réservations %N")
				io.put_string("2. Consulter mes emprunts %N")
				io.put_string("3. Annuler une réservation %N")
				io.put_string("4. Retour %N")
				io.put_string("%N")
				io.flush
				io.read_integer
				choix_gestion := io.last_integer
				if choix_gestion > 0 and choix_gestion < 5 then
					inspect choix_gestion
					when 1 then 
						afficher_reservations
					when 2 then
						afficher_emprunts
					when 3 then
						annuler_reservation
					when 4 then
						continuer := False
					end
				else
					io.put_string("Saississez un nombre compris entre 1 et 4 %N")
				end
			end
		end
		
	-- affichage de toutes les réservations actuelles de l'utilisateur connecte
	afficher_reservations is
		local 
			i : INTEGER
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      MES RESERVATIONS        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_reservations.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre /= Void then
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre.to_string+"%N")
				else
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_dvd.to_string+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_reservations.count = 0 then
				io.put_string("Aucune réservation en cours ! %N")
			end
			io.put_string("%N %N")
		end
		
	-- affichage de tous les emprunts actuels de l'utilisateur connecte
	afficher_emprunts is
		local 
			i : INTEGER
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*          MES EMPRUNTS        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_emprunts.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_livre /= Void then
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_livre.to_string+"%N")
				else
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_dvd.to_string+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_emprunts.count = 0 then
				io.put_string("Aucun emprunt en cours ! %N")
			end
			io.put_string("%N %N")
		end
		
	-- annulation d'une réservation par l'utilisateur connecte
	annuler_reservation is 
		local 
			i : INTEGER
			choix : INTEGER
			correct : BOOLEAN
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*        MES RESERVATIONS      *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_reservations.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre /= Void then
					io.put_string((i+1).to_string + ". " + mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre.get_titre+"%N")
				else
					io.put_string((i+1).to_string + ". " + mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_dvd.get_titre+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_reservations.count = 0 then
				io.put_string("Aucune réservation en cours ! %N")
			else
				correct := False
				from
				until correct 
				loop
					io.put_string("Quelle réservation souhaitez vous annuler ? (Saississez son numéro)%N")
					io.flush
					io.read_integer
					choix := io.last_integer
					if choix > 0 and choix <= i then
						correct := True
						-- suppression de la réservation dans le fichier						
						supprimer_reservation_fichier(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(choix-1))
						-- suppression de la réservation dans la liste de l'utilisateur
						mediatheque.get_utilisateur_connecte.get_lst_reservations.remove(choix-1)
						-- la réservation est dissocié du média dans la liste
						supprimer_reservation_liste_medias(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(choix-1))
						io.put_string("Réservation annulée %N")
					end
				end
			end
			io.put_string("%N %N")
		end 
	-- fin d'un emprunt, l'ouvrage est de nouveau disponbile (réaliser par un administrateur)
	retourner_emprunt is
			local
				identifiant : STRING
				i : INTEGER
				correct : BOOLEAN
				compteur: INTEGER
				choix : INTEGER
				utilisateur : UTILISATEUR
			do
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*      RETOURNER UN EMPRUNT    *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				correct := False
				compteur := 1
				from
				until correct or compteur = 4
				loop
					io.put_string("Identifiant de l'utilisateur : %N")
					io.flush
					if compteur = 1 then
						io.read_line
					end
					io.read_line
					identifiant := io.last_string
					from i := 0
					until i = mediatheque.get_lst_users.count
					loop
						if mediatheque.get_lst_users.item(i).get_identifiant.is_equal(identifiant) then
							correct := True
							utilisateur := mediatheque.get_lst_users.item(i)
						end
						i := i+1
					end
					if not correct then 
						io.put_string("Identifiant inconnu. %N")
					end
					compteur := compteur + 1 
				end
				if compteur = 4 then 
					io.put_string("Abandon du retour de l'ouvrage.")
				end
				if correct then
					io.put_string("***** Emprunts de l'utilisateur *****%N")
					if  utilisateur.get_lst_emprunts.count > 0 then
						from i := 0
						until i = utilisateur.get_lst_emprunts.count
						loop
							if utilisateur.get_lst_emprunts.item(i).get_dvd /= Void then
								io.put_string((i+1).to_string+". "+utilisateur.get_lst_emprunts.item(i).get_dvd.get_titre+"%N")
							else
								io.put_string((i+1).to_string+". "+utilisateur.get_lst_emprunts.item(i).get_livre.get_titre+"%N")
							end
							i:= i+1
						end
						io.put_string("%N")
						correct := False
						from
						until correct
						loop
							io.put_string("Quel emprunt se termine ? (Saisissez son numéro)%N")
							io.flush
							io.read_integer
							choix := io.last_integer
							if choix > 0 and choix <= i then							
								-- suppression de l'emprunt pour le média concerné dans la liste des médias
								supprimer_emprunt_liste_medias(utilisateur.get_lst_emprunts.item(choix-1))
								--suppression de l'emprunt du fichier des emprunts
								supprimer_emprunt_fichier(utilisateur.get_lst_emprunts.item(choix-1))
								-- suppression de l'emprunt de la liste de l'utilisateur concerné
								utilisateur.get_lst_emprunts.remove(choix-1)
								correct := True
								io.put_string("Emprunt terminé ! %N")
							end
						end
					else
						io.put_string("Aucun emprunt en cours ! %N")
					end
				end
			end
			
	-- un administrateur peut annuler une réservation pour n'importe quel utilisateur à partir de son identifiant		
	annuler_reservation_admin is
			local
				identifiant : STRING
				i : INTEGER
				correct : BOOLEAN
				compteur: INTEGER
				choix : INTEGER
				utilisateur : UTILISATEUR
			do
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*    ANNULATION RESERVATION    *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				correct := False
				compteur := 1
				from
				until correct or compteur = 4
				loop
					io.put_string("Identifiant de l'utilisateur : %N")
					io.flush
					if compteur =1 then
						io.read_line
					end
					io.read_line
					identifiant := io.last_string
					from i := 0
					until i = mediatheque.get_lst_users.count
					loop
						if mediatheque.get_lst_users.item(i).get_identifiant.is_equal(identifiant) then
							correct := True
							utilisateur := mediatheque.get_lst_users.item(i)
						end
						i := i+1
					end
					if not correct then 
						io.put_string("Identifiant inconnu. %N")
					end
					compteur := compteur + 1 
				end
				if compteur = 4 then 
					io.put_string("Réservation toujours active !")
				end
				if correct then
					io.put_string("***** Réservations de l'utilisateur ***** %N")
					if utilisateur.get_lst_reservations.count > 0 then
						from i := 0
						until i = utilisateur.get_lst_reservations.count
						loop
							if utilisateur.get_lst_reservations.item(i).get_dvd /= Void then
								io.put_string((i+1).to_string+". "+utilisateur.get_lst_reservations.item(i).get_dvd.get_titre+"%N")
							else
								io.put_string((i+1).to_string+". "+utilisateur.get_lst_reservations.item(i).get_livre.get_titre+"%N")
							end
							i:= i+1
						end
						io.put_string("%N")
						correct := False
						from
						until correct
						loop
							io.put_string("Quel réservation doit être annulée ? (Saisissez son numéro)%N")
							io.flush
							io.read_integer
							choix := io.last_integer
							if choix > 0 and choix <= i then
								--suppression de la réservation dans le fichier des réservations
								supprimer_reservation_fichier(utilisateur.get_lst_reservations.item(choix-1))
								-- suppression de la réservation dans la liste de l'utilisateur concerné
								utilisateur.get_lst_reservations.remove(choix-1)
								-- suppression de la réservation pour le média concerné
								supprimer_reservation_liste_medias(utilisateur.get_lst_reservations.item(choix-1))
								correct := True
								io.flush
								io.put_string("Réservation annulée ! %N")
							end
						end
					else
						io.put_string("Aucune réservation en cours ! %N")
					end
				end
			end	
	
	-- parcours du fichier et suppression de la réservation en réécrivant le fichier
	supprimer_reservation_fichier (reservation: RESERVATION) is
		local
			fichier_read: TEXT_FILE_READ
			fichier_write : TEXT_FILE_WRITE
			ligne : STRING
			contenu_fichier : ARRAY[STRING]
			i : INTEGER
		do
			ligne := ""
			create fichier_read.make
			create contenu_fichier.with_capacity(1,0)
			fichier_read.connect_to("reservations.txt")
			if fichier_read.is_connected then
				from
				until fichier_read.end_of_input
				loop
					ligne := ""
					fichier_read.read_line_in(ligne)
					if not ligne.has_substring("Numero<"+reservation.get_numero+">") then
						contenu_fichier.add_last(ligne)
					end
				end
				fichier_read.disconnect
				create fichier_write.make
				fichier_write.connect_to("reservations.txt")
				from i := 0
				until i = contenu_fichier.count
				loop
					fichier_write.put_string(contenu_fichier.item(i)+"%N")
					i := i+1
				end
				fichier_write.disconnect
			end
					
		end
	
	-- un administrateur peut réaliser un emprunt pour un utilisateur à partir de sa liste de réservation
	transformer_reservation_emprunt is 
		local
			fichier_emprunt : TEXT_FILE_WRITE
			utilisateur : UTILISATEUR
			emprunt : EMPRUNT
			reservation : RESERVATION
			i : INTEGER
			ajout : BOOLEAN
			correct : BOOLEAN
			compteur : INTEGER
			choix : INTEGER
			identifiant : STRING
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*     RESERVATION -> EMPRUNT   *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			correct := False
			compteur := 1
			from
			until correct or compteur = 4
			loop
				io.put_string("Identifiant de l'utilisateur : %N")
				io.flush
				io.read_line
				io.read_line
				identifiant := io.last_string
				from i := 0
				until i = mediatheque.get_lst_users.count
				loop
					if mediatheque.get_lst_users.item(i).get_identifiant.is_equal(identifiant) then
						correct := True
						utilisateur := mediatheque.get_lst_users.item(i)
					end
					i := i+1
				end
				if not correct then 
					io.put_string("Identifiant inconnu. %N")
				end
				compteur := compteur + 1 
			end
			if compteur = 4 then 
				io.put_string("Réservation toujours active !")
			end
			if correct then
				io.put_string("***** Réservations de l'utilisateur ***** %N")
				if utilisateur.get_lst_reservations.count > 0 then
					from i := 0
					until i = utilisateur.get_lst_reservations.count
					loop
						if utilisateur.get_lst_reservations.item(i).get_dvd /= Void then
							io.put_string((i+1).to_string+". "+utilisateur.get_lst_reservations.item(i).get_dvd.get_titre+"%N")
						else
							io.put_string((i+1).to_string+". "+utilisateur.get_lst_reservations.item(i).get_livre.get_titre+"%N")
						end
						i:= i+1
					end
					io.put_string("%N")
					correct := False
					from
					until correct
					loop
						io.put_string("Quelle réservation devient un emprunt ? (Saisissez son numéro)%N")
						io.flush
						io.read_integer
						choix := io.last_integer
						if choix > 0 and choix <= i then
							correct := True
							reservation := utilisateur.get_lst_reservations.item(choix-1)							
							create emprunt.make
							emprunt.set_numero(generer_numero)
							emprunt.set_user(utilisateur)
							if reservation.get_dvd /= Void then
								emprunt.set_dvd(reservation.get_dvd)
							else
								emprunt.set_livre(reservation.get_livre)
							end
							ajouter_emprunt_liste_medias(emprunt)
							ajout := utilisateur.ajouter_emprunt(emprunt)
							if not ajout then
								io.put_string("L'utilisateur ne peut pas emprunter plus %N")
							else
								supprimer_reservation_fichier(reservation)
								utilisateur.get_lst_reservations.remove(choix-1)
								supprimer_reservation_liste_medias(reservation)
								create fichier_emprunt.make
								fichier_emprunt.connect_for_appending_to("emprunts.txt")
								fichier_emprunt.put_line(emprunt.format_enregistrement)
								fichier_emprunt.disconnect
								io.put_string("Emprunt réalisé ! %N")
							end
						else
							io.put_string("Le média n'existe pas %N")
						end -- choix correct
					
					
					end -- loop correct
				else
					io.put_string("Pas de réservation pour cet utilisateur.%N%N")
				end
			end--identifiant correct
		end
		
	-- aprcours du fichier des emprunts et réécriture sans l'emprunt supprimé
	supprimer_emprunt_fichier (emprunt: EMPRUNT) is
		local
			fichier_read: TEXT_FILE_READ
			fichier_write : TEXT_FILE_WRITE
			ligne : STRING
			contenu_fichier : ARRAY[STRING]
			i : INTEGER
		do
			ligne := ""
			create fichier_read.make
			create contenu_fichier.with_capacity(1,0)
			fichier_read.connect_to("emprunts.txt")
			if fichier_read.is_connected then
				from
				until fichier_read.end_of_input
				loop
					ligne := ""
					fichier_read.read_line_in(ligne)
					if not ligne.has_substring("Numero<"+emprunt.get_numero+">") then
						contenu_fichier.add_last(ligne)
					end
				end
				fichier_read.disconnect
				create fichier_write.make
				fichier_write.connect_to("emprunts.txt")
				from i := 0
				until i = contenu_fichier.count
				loop
					fichier_write.put_string(contenu_fichier.item(i)+"%N")
					i := i+1
				end
				fichier_write.disconnect
			end					
		end
	
	-- parcours de la liste des médias et suppression de la réservation
	supprimer_reservation_liste_medias (reservation : RESERVATION) is
		local
			i : INTEGER
		do
			if reservation.get_dvd /= Void then
				from i := 0
				until i = mediatheque.get_lst_dvd.count
				loop
					if mediatheque.get_lst_dvd.item(i).get_titre.is_equal(reservation.get_dvd.get_titre) then
						mediatheque.get_lst_dvd.item(i).supprimer_reservation(reservation)
					end
					i := i+1
				end
			else
				from i := 0
				until i = mediatheque.get_lst_livres.count
				loop
					if mediatheque.get_lst_livres.item(i).get_titre.is_equal(reservation.get_livre.get_titre) then
						mediatheque.get_lst_livres.item(i).supprimer_reservation(reservation)
					end
					i := i+1
				end 
			end
		end
		
	-- parcours de la liste des médias et suppression de l'emprunt
	supprimer_emprunt_liste_medias (emprunt : EMPRUNT) is
		local
			i : INTEGER
		do
			if emprunt.get_dvd /= Void then
				from i := 0
				until i = mediatheque.get_lst_dvd.count
				loop
					if mediatheque.get_lst_dvd.item(i).get_titre.is_equal(emprunt.get_dvd.get_titre) then
						mediatheque.get_lst_dvd.item(i).supprimer_emprunt(emprunt)
					end
					i := i+1
				end
			else
				from i := 0
				until i = mediatheque.get_lst_livres.count
				loop
					if mediatheque.get_lst_livres.item(i).get_titre.is_equal(emprunt.get_livre.get_titre) then
						mediatheque.get_lst_livres.item(i).supprimer_emprunt(emprunt)
					end
					i := i+1
				end 
			end
		end
	
	-- ajout du nouvel emprunt associé au média
	ajouter_emprunt_liste_medias (emprunt : EMPRUNT) is
		local
			i : INTEGER
			ajouter : STRING
		do
			if emprunt.get_dvd /= Void then
				from i := 0
				until i = mediatheque.get_lst_dvd.count
				loop
					if mediatheque.get_lst_dvd.item(i).get_titre.is_equal(emprunt.get_dvd.get_titre) then
						ajouter := mediatheque.get_lst_dvd.item(i).ajouter_emprunt(emprunt)
					end
					i := i+1
				end
			else
				from i := 0
				until i = mediatheque.get_lst_livres.count
				loop
					if mediatheque.get_lst_livres.item(i).get_titre.is_equal(emprunt.get_livre.get_titre) then
						ajouter := mediatheque.get_lst_livres.item(i).ajouter_emprunt(emprunt)
					end
					i := i+1
				end 
			end
		end
		
	-- affiche la liste des utilisateurs ayant effctué une réservation ainsi que leurs réservations
	afficher_utilisateurs_et_reservation is
		local
			i,j: INTEGER
			utilisateur: UTILISATEUR
		do
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*    LISTE DES RESERVATIONS    *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i:=0
			until i= mediatheque.get_lst_users.count
			loop
				utilisateur := mediatheque.get_lst_users.item(i)
				if utilisateur.get_lst_reservations.count > 0 then
					io.put_string(utilisateur.get_identifiant + " : "+utilisateur.get_prenom+" "+utilisateur.get_nom+": %N")
					from j := 0
					until j = utilisateur.get_lst_reservations.count
					loop
						io.put_string(utilisateur.get_lst_reservations.item(j).afficher_contenu_reservation+"%N")
						j := j+1
					end
					io.put_string("--------------------------------%N")
				end
				i := i+1
			end
		end
		
	--affiche la liste des utilisateurs ayant réalisé un emprunt ainsi que la liste de leurs emprunts
	afficher_utilisateurs_et_emprunts is
		local
			i,j: INTEGER
			utilisateur: UTILISATEUR
		do
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      LISTE DES EMPRUNTS      *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i:=0
			until i= mediatheque.get_lst_users.count
			loop
				utilisateur := mediatheque.get_lst_users.item(i)
				if utilisateur.get_lst_emprunts.count > 0 then
					io.put_string(utilisateur.get_identifiant + " : "+utilisateur.get_prenom+" "+utilisateur.get_nom+": %N")
					from j := 0
					until j = utilisateur.get_lst_emprunts.count
					loop
						io.put_string(utilisateur.get_lst_emprunts.item(j).afficher_contenu_emprunt+"%N")
						j := j+1
					end
					io.put_string("--------------------------------%N")
				end
				i := i+1
			end
		end
	-- affichage du ménu permettant à l'admnistrateur de gérer ses emprunts et ses réservations ainsi que ceux des autres autilisateurs
	gerer_emprunts_reservations_admin is
		local
			continuer : BOOLEAN
			choix_gestion : INTEGER
		do
			continuer := True
			from
			until not continuer
			loop
				io.put_string("%N")
				io.put_string("*********************************")
				io.put_string("%N")
				io.put_string("* GESTION EMPRUNT & RESERVATION *")
				io.put_string("%N")
				io.put_string("*********************************")
				io.put_string("%N")
				io.put_string("Que souhaiter vous faire? %N")
				io.put_string("1. Consulter les réservations %N")
				io.put_string("2. Consulter les emprunts %N")
				io.put_string("3. Retourner un ouvrage %N")
				io.put_string("4. Annuler une réservation %N")
				io.put_string("5. Réaliser un emprunt à partir d'une réservation %N")
				io.put_string("6. Retour %N")
				io.flush
				io.read_integer
				choix_gestion := io.last_integer
				if choix_gestion > 0 and choix_gestion < 7 then
					inspect choix_gestion
					when 1 then 
						afficher_utilisateurs_et_reservation
					when 2 then
						afficher_utilisateurs_et_emprunts
					when 3 then
						retourner_emprunt
					when 4 then 
						annuler_reservation_admin
					when 5 then
						transformer_reservation_emprunt
					when 6 then
						continuer := False
					end
				else
					io.put_string("Saississez un nombre compris entre 1 et 4 %N")
				end
			end
		end
	
	-- génrère le numéro de réservation et d'emprunt à partir du timestamp	
	generer_numero : STRING is
		local
			time : TIME
		do
			time.set_local_time
			time.update
			Result := time.year.to_string+time.month.to_string+time.day.to_string+time.hour.to_string+time.minute.to_string+time.second.to_string
		end

end
