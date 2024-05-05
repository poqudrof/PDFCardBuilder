require 'yaml'

# Chargement du fichier YAML
batiments = YAML.load_file('bat.yaml')

# Définition des bâtiments requis
batiments_requis = {
  "Château" => 1,
  "Maison" => 3,
  "Champs" => 3,
  "École" => 1,
  "Manoir" => 1,
  "Tour de Guet" => 2
}

# Fonction pour calculer le coût total
def calculer_cout_total(batiments, batiments_requis)
  cout_total = 0

  batiments_requis.each do |nom, quantite|
    batiment = batiments.find { |b| b["nom"] == nom }
    raise "Bâtiment non trouvé : #{nom}" unless batiment

    cout_total += (batiment["coût"]["bois"] + batiment["coût"]["pierre"]) * quantite
  end

  return cout_total
end

# Calcul du coût total des bâtiments requis
cout_total = calculer_cout_total(batiments, batiments_requis)
puts "Le coût total des bâtiments requis est de #{cout_total} pièces d'or."
