class GESTIONNAIRE_EMPRUNT_RESERVATION

creation{ANY}
	make

feature{}
	lst_medias: ARRAY[MEDIA] -- liste des medias
 	lst_acteurs: ARRAY[ACTEUR] --liste des acteurs
 	lst_realisateurs: ARRAY[REALISATEUR] --liste des réalisateurs
  	lst_auteurs: ARRAY[AUTEUR] -- liste des auteurs
  	lst_livres: ARRAY[LIVRE] -- liste des livres
  	lst_dvd : ARRAY[DVD] -- liste des dvd
  	lst_media_choisis : ARRAY[MEDIA] -- liste des médias à afficher
  	mediatheque : MEDIATHEQUE

feature{ANY}
	make (m : MEDIATHEQUE) is
		do
			mediatheque := m
		end
	
	remplir_lst_reservations is
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
			une_resa : RESERVATION
			priorite : INTEGER
			resa_ajouter : BOOLEAN
			numero : INTEGER
			
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
						
							if ligne_tab.item(j).has_substring("Numero") then								
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								numero := (ligne_tab.item(j).substring(index_start+1, index_end-1)).to_integer
							end
					
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
						create une_resa.make
						une_resa.set_user(user)
						une_resa.set_priorite(priorite)
						une_resa.set_numero(numero)
						if index_dvd > -1 then
							une_resa.set_dvd(dvd)
							resa_ajouter := mediatheque.get_lst_dvd.item(index_dvd).ajouter_reservation(une_resa)
						else
							if index_livre > -1 then
								une_resa.set_livre(livre)
								resa_ajouter := mediatheque.get_lst_livres.item(index_livre).ajouter_reservation(une_resa)
							end
						end
						if index_user > -1 then
							resa_ajouter := mediatheque.get_lst_users.item(index_user).ajouter_reservation(une_resa)
						end
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							resa_ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
			
		end
		
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
			numero : INTEGER
			
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
							if ligne_tab.item(j).has_substring("Numero")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								numero := (ligne_tab.item(j).substring(index_start+1, index_end-1)).to_integer
							end
						
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
						create un_emp.make
						un_emp.set_user(user)
						un_emp.set_numero(numero)
						if index_dvd > -1 then
							un_emp.set_dvd(dvd)
							emp_ajouter := mediatheque.get_lst_dvd.item(index_dvd).ajouter_emprunt(un_emp)
						else
							un_emp.set_livre(livre)
							emp_ajouter := mediatheque.get_lst_livres.item(index_livre).ajouter_emprunt(un_emp)
						end
						emp_ajouter_media := mediatheque.get_lst_users.item(index_user).ajouter_emprunt(un_emp)
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							emp_ajouter_media := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emp)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
		end
		
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
			time : TIME
		do
			is_livre := False
			ajouter := False
			time.set_local_time
			time.update
			
			
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
			reserver := False
			if is_livre then
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_livre(livre)
				un_emprunt.set_numero((time.year.to_string+time.month.to_string+time.day.to_string+time.hour.to_string+time.minute.to_string).to_integer)
				ajouter_ds_media := livre.ajouter_emprunt(un_emprunt)
				if ajouter_ds_media = "NON" then
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
				if ajouter_ds_media.is_equal("FAIT") then
					io.put_string("Vous empruntez déjà ce livre! %N")
					reserver := False
				end			
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
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré !%N")
				end
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_user(mediatheque.get_utilisateur_connecte)
					une_resa.set_livre(livre)
					une_resa.set_numero((time.year.to_string+time.month.to_string+time.day.to_string+time.hour.to_string+time.minute.to_string).to_integer)
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
					if ajouter then
						create fichier_reservation.make
						fichier_reservation.connect_for_appending_to("reservations.txt")
						fichier_reservation.put_line(une_resa.format_enregistrement)
						fichier_reservation.disconnect
						io.put_string("Réservation effectuée ! %N")
					end
				end
			else
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_dvd(dvd)
				un_emprunt.set_numero((time.year.to_string+time.month.to_string+time.day.to_string+time.hour.to_string+time.minute.to_string).to_integer)
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
				
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré ! %N")
				end
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_numero((time.year.to_string+time.month.to_string+time.day.to_string+time.hour.to_string+time.minute.to_string).to_integer)
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
		
	gerer_emprunt_reservation is
		local
			continuer : BOOLEAN
			choix_gestion : INTEGER
		do
			continuer := True
			from
			until not continuer
			loop
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
		
	afficher_emprunts is
		local 
			i : INTEGER
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      MES EMPRUNTS            *")
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
		
	annuler_reservation is 
		local 
			i : INTEGER
			choix : INTEGER
			correct : BOOLEAN
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
					io.put_string("Quelle réservation souhaitez vous annuler ? (Saississez un numéro)%N")
					io.flush
					io.read_integer
					choix := io.last_integer
					if choix > 0 and choix <= i then
						correct := True						
						supprimer_reservation_fichier(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(choix-1))
						mediatheque.get_utilisateur_connecte.get_lst_reservations.remove(choix-1)
						io.put_string("Réservation annulée %N")
					end
				end
			end
			io.put_string("%N %N")
		end 
		
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
				io.put_string("*      RETOUR                  *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("%N")
				correct := False
				compteur := 1
				from
				until correct or compteur = 4
				loop
					io.put_string("Tapez l'identifiant d'un utilisateur : %N")
					io.flush
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
						io.put_string("identifiant inconnu %N")
					end
					compteur := compteur + 1 
				end
				if compteur = 4 then 
					io.put_string("abandon du retour de l'ouvrage")
				end
				if correct then
					io.put_string("********Emprunts de l'utilisateur********* %N %N")
					from i := 0
					until i = utilisateur.get_lst_emprunts.count
					loop
						if utilisateur.get_lst_emprunts.item(i).get_dvd /= Void then
							io.put_string((i+1).to_string+" ."+utilisateur.get_lst_emprunts.item(i).get_dvd.get_titre+"%N")
						else
							io.put_string((i+1).to_string+" ."+utilisateur.get_lst_emprunts.item(i).get_livre.get_titre+"%N")
						end
						i:= i+1
					end
					io.put_string("%N")
					correct := False
					from
					until correct
					loop
						io.put_string("Quel emprunt se termine ? (Saisissez un numéro)")
						io.flush
						io.read_integer
						choix := io.last_integer
						if choix > 0 and choix <= i then
							supprimer_emprunt_fichier(utilisateur.get_lst_emprunts.item(choix-1))
							utilisateur.get_lst_emprunts.remove(choix-1)
							correct := True
							io.put_string("Emprunt terminé ! %N")
						end
					end
				end
			end		
			
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
					fichier_read.read_line_in(ligne)
					if not ligne.has_substring("Numero<"+reservation.get_numero.to_string+">") then
						contenu_fichier.add_last(ligne)
					end
				end
				fichier_read.disconnect
				create fichier_write.make
				fichier_write.connect_to("reservations.txt")
				from i := 0
				until i = contenu_fichier.count
				loop
					fichier_write.put_line(contenu_fichier.item(i))
					i := i+1
				end
				fichier_write.disconnect
			end
					
		end
		
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
					fichier_read.read_line_in(ligne)
					if not ligne.has_substring("Numero<"+emprunt.get_numero.to_string+">") then
						contenu_fichier.add_last(ligne)
					end
				end
				fichier_read.disconnect
				create fichier_write.make
				fichier_write.connect_to("emprunts.txt")
				from i := 0
				until i = contenu_fichier.count
				loop
					fichier_write.put_line(contenu_fichier.item(i))
					i := i+1
				end
				fichier_write.disconnect
			end					
		end
		
	afficher_utilisateurs_et_reservation is
		local
			i,j: INTEGER
			utilisateur: UTILISATEUR
		do
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*    Liste des reservations    *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i:=0
			until i= mediatheque.get_lst_users.count
			loop
				utilisateur := mediatheque.get_lst_users.item(i)
				if utilisateur.get_lst_reservations.count > 0 then
					io.put_string(utilisateur.get_identifiant + " :"+utilisateur.get_prenom+" "+utilisateur.get_nom+":%N")
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
		
	afficher_utilisateurs_et_emprunts is
		local
			i,j: INTEGER
			utilisateur: UTILISATEUR
		do
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*    Liste des emprunts        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i:=0
			until i= mediatheque.get_lst_users.count
			loop
				utilisateur := mediatheque.get_lst_users.item(i)
				if utilisateur.get_lst_emprunts.count > 0 then
					io.put_string(utilisateur.get_identifiant + " :"+utilisateur.get_prenom+" "+utilisateur.get_nom+":%N")
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
		
	gerer_emprunts_reservations_admin is
		local
			continuer : BOOLEAN
			choix_gestion : INTEGER
		do
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("* Gestion Emprunt/Reservation  *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			continuer := True
			from
			until not continuer
			loop
				io.put_string("Que souhaiter vous faire? %N")
				io.put_string("1. Consulter les réservations %N")
				io.put_string("2. Consulter les emprunts %N")
				io.put_string("3. Retourner un ouvrage %N")
				io.put_string("4. Retour %N")
				io.put_string("%N")
				io.flush
				io.read_integer
				choix_gestion := io.last_integer
				if choix_gestion > 0 and choix_gestion < 5 then
					inspect choix_gestion
					when 1 then 
						afficher_utilisateurs_et_reservation
					when 2 then
						afficher_utilisateurs_et_emprunts
					when 3 then
						retourner_emprunt
					when 4 then
						continuer := False
					end
				else
					io.put_string("Saississez un nombre compris entre 1 et 4 %N")
				end
			end
		end
		
		
	end
