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
    
    @pdf.move_up(-50)

    cartes.each_slice(2) do |slice|
      slice.each_with_index do |carte, index|
        
    
        x_position = index.even? ? 0 : mm_to_pt(70) # Définir la position X en fonction de la parité de l'index
        y_position = @pdf.cursor
  
        if y_position < mm_to_pt(88) # Si la hauteur restante n'est pas suffisante pour dessiner une carte complète, démarrer une nouvelle page
          @pdf.start_new_page
          @pdf.move_up(-50)
          y_position = @pdf.cursor # Réinitialiser la position Y
        end
  
        @pdf.bounding_box([x_position, y_position], width: mm_to_pt(62), height: mm_to_pt(88)) do
          draw_card_background(fond_path)
          draw_rounded_card
          p "loading #{carte['nom'].downcase.gsub(' ', '_')}.png"
          draw_card_content(carte, "images/#{carte['nom'].downcase.gsub(' ', '_')}.png")
        end

        @pdf.move_up mm_to_pt(88) if index.even?
        
      end
      
      @pdf.move_up -10
    end
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

    @pdf.move_down 25

    @pdf.text carte["nom"], align: :center, size: 14, style: :bold
    
    @pdf.move_down 15
    # Dessiner le coût de la carte
    # draw_identifiant(carte["coût"])

    @pdf.text_box carte["coût"], size: 14, width: 40, align: :center,
     at: [@pdf.bounds.right - carte["coût"].length * 1.6 - 46, @pdf.bounds.top - 7]

    @pdf.move_down -14

    @pdf.image image_path, fit: [@pdf.bounds.width - 10, @pdf.bounds.height - 60], position: :center
    
    # Dessiner les symboles autour de la carte
    draw_symbols(carte["symboles"])

    @pdf.text_box carte["note"], at: [@pdf.bounds.left + 30, @pdf.bounds.bottom + 106],
     width: @pdf.bounds.width - 60, height: @pdf.bounds.height - 60, align: :center, size: 10

  end

  def draw_symbols(symboles)
    symbol_size = 25

    # Position des symboles
    positions = {
      top:    [@pdf.bounds.width / 2 - symbol_size/2,  @pdf.bounds.top - 5],
      bottom: [@pdf.bounds.width / 2 - symbol_size/2,  @pdf.bounds.bottom + 5 + symbol_size],
      left:   [@pdf.bounds.left + 5, @pdf.bounds.height / 2 - symbol_size/2 - 15],
      right:  [@pdf.bounds.right - symbol_size - 5, @pdf.bounds.height / 2 - symbol_size/2 - 15]
    }


    # Mélanger les symboles de manière aléatoire
    shuffled_symboles = (symboles + symboles + symboles+ symboles).shuffle

    # Remplir un tableau de taille 4 avec des symboles aléatoires
    positions.keys.each do |position|
      symbole = shuffled_symboles.pop
      @pdf.image "images/#{symbole}.png", at: positions[position], width: symbol_size, height: symbol_size
    end
  end
end

carte_pdf = CarteJouerPDF.new

carte_pdf.add_cartes_from_yaml("bat.yaml", "fond3.png")
carte_pdf.generate_pdf("batiments.pdf")
