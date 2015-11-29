class LIVRE inherit
	MEDIA
	rename make as make_media
	end

creation{ANY}
	make

feature{}
	auteur: AUTEUR
feature {ANY}
	make is 
		do
			make_media
			create auteur.make
		end
	
	make_from_media (m: MEDIA) is
		do
			titre := m.get_titre
			nombre_exemplaires := m.get_nombre_exemplaires
		end
		
	set_auteur (a: AUTEUR) is
		do
			auteur:= a
		end
	
	get_auteur : AUTEUR is
		do
			Result:= auteur
		end
end
