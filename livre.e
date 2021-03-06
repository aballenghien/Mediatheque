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
		
	to_string : STRING is
		do
			Result := "LIVRE : "+titre
		end
		
	-- getter et setter
	set_auteur (a: AUTEUR) is
		do
			auteur:= a
		end
	
	get_auteur : AUTEUR is
		do
			Result:= auteur
		end
end
