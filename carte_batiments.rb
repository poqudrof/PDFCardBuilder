require 'prawn'

require 'prawn/emoji'

class CarteJouerPDF
  def initialize
    @pdf = Prawn::Document.new
 
    @pdf.font_families.update(
      "OpenSans" => {
        normal: "OpenSans-VariableFont_wdth,wght.ttf",
        bold: "OpenSans-VariableFont_wdth,wght.ttf"
      }
      )
    @pdf.font("OpenSans")
  end

  def add_cartes_from_yaml(yaml_file, fond_path)
    cartes = YAML.load_file(yaml_file)
    cartes.each { |carte| add_carte(carte, fond_path) }
  end 

  def add_carte(carte, fond_path)
    p "Loading card #{carte}..."
    @pdf.start_new_page unless @pdf.cursor == @pdf.bounds.height

    card_width = mm_to_pt(62)
    card_height = mm_to_pt(88)

    image_path = "images/#{carte['nom'].downcase.gsub(' ', '_')}.png"
   
    @pdf.bounding_box([0, @pdf.cursor], width: card_width, height: card_height) do
      draw_card_background(fond_path)
      draw_rounded_card
      draw_card_content(carte, image_path)
    end

    @pdf.move_down 10
  end

  def generate_pdf(file_name)
    @pdf.render_file(file_name)
  end

  private

  # Conversion de mm en points (1 mm = 2.83465 points)
  def mm_to_pt(mm)
    mm * 2.83465
  end

  def draw_rounded_card
    @pdf.rounded_rectangle [0, @pdf.cursor], @pdf.bounds.width, @pdf.bounds.height, 5
    @pdf.stroke
  end


  def draw_card_background(fond_path)
    @pdf.image fond_path, at: [0, @pdf.cursor], width: @pdf.bounds.width, height: @pdf.bounds.height#, fit: [@pdf.bounds.width, @pdf.bounds.height]
  end

  def draw_card_content(carte, image_path)

    @pdf.move_down 30

    @pdf.text carte["nom"], align: :center, size: 14, style: :bold
    
    @pdf.move_down 15
    # Dessiner le coût de la carte
    draw_identifiant(carte["coût"])

    @pdf.move_down 45
    @pdf.image image_path, fit: [@pdf.bounds.width - 10, @pdf.bounds.height - 60], position: :center
    
    # Dessiner les symboles autour de la carte
    draw_symbols(carte["symboles"])
  end

  def draw_identifiant(identifiant)
    identifiant_width = 40
    identifiant_height = 10
    identifiant_x = @pdf.bounds.width - identifiant_width - 12
    identifiant_y = @pdf.bounds.top - identifiant_height - 2
  
    @pdf.bounding_box([identifiant_x, identifiant_y], width: identifiant_width, height: identifiant_height) do
      @pdf.fill_color "F0F0F0" # Couleur de fond clair
      @pdf.stroke_color "222222" # Couleur de contour
      @pdf.fill_rectangle [0, identifiant_height], identifiant_width, identifiant_height
      @pdf.fill_color "000000" # Réinitialiser la couleur de remplissage à la valeur par défaut
     #  @pdf.text identifiant, align: :right, valign: :center, size: 8
      @pdf.text_box identifiant, at: [-12, 10], width: 40, height: 12, align: :right, size: 8
   
    end
  end
  

  def draw_symbols(symboles)
    symbol_size = 25

    # Position des symboles
    positions = {
      top:    [@pdf.bounds.width / 2 - symbol_size/2,  @pdf.bounds.top - 5],
      bottom: [@pdf.bounds.width / 2 - symbol_size/2,  @pdf.bounds.bottom + 5 + symbol_size],
      left:   [@pdf.bounds.left + 5, @pdf.bounds.height / 2 - symbol_size/2 - 28],
      right:  [@pdf.bounds.right - symbol_size - 5, @pdf.bounds.height / 2 - symbol_size/2 - 28]
    }


    # Mélanger les symboles de manière aléatoire
    shuffled_symboles = (symboles + symboles).shuffle

    # Remplir un tableau de taille 4 avec des symboles aléatoires
    positions.keys.each do |position|
      symbole = shuffled_symboles.pop
      @pdf.image "images/#{symbole}.png", at: positions[position], width: symbol_size, height: symbol_size
    end

    # # Dessiner les symboles
    # symboles.each do |symbole|
    #   @pdf.image "images/#{symbole}.png", at: positions[:top], width: symbol_size, height: symbol_size
    #   @pdf.image "images/#{symbole}.png", at: positions[:bottom], width: symbol_size, height: symbol_size
    #   @pdf.image "images/#{symbole}.png", at: positions[:left], width: symbol_size, height: symbol_size
    #   @pdf.image "images/#{symbole}.png", at: positions[:right], width: symbol_size, height: symbol_size
    # end

  end
end

carte_pdf = CarteJouerPDF.new

carte_pdf.add_cartes_from_yaml("bat.yaml", "fond3.png")
carte_pdf.generate_pdf("batiments.pdf")
