require 'prawn'
require 'prawn/emoji'

class CarteJouerPDF
  # def initialize
  #   @pdf = Prawn::Document.new
  #   @pdf.font("Helvetica")
  # end

  def initialize(font_path)
    @pdf = Prawn::Document.new
    # @pdf.font(font_path)

    @pdf.font_families.update(
      "OpenSans" => {
        normal: "OpenSans-VariableFont_wdth,wght.ttf",
        bold: "OpenSans-VariableFont_wdth,wght.ttf"
      }
      )
    @pdf.font("OpenSans")
  end


  def add_carte_from_yaml(yaml_file, fond_path, carte_logo_path)
    animaux = YAML.load_file(yaml_file)
    
    @pdf.move_up(-50)

    animaux.each_slice(2) do |slice|
      slice.each_with_index do |animal, index|
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
          # draw_logo(carte_logo_path)
          # draw_card_content(animal["Nom"], animal["Prix"], "images/#{animal['Nom'].downcase.gsub(' ', '_')}.png", animal["Capacité"])
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

  def draw_logo(carte_logo_path)
    @pdf.image carte_logo_path, at: [5, @pdf.cursor - 5], width: 20, height: 20
  end

  def draw_card_background(fond_path)
    @pdf.image fond_path, at: [0, @pdf.cursor], width: @pdf.bounds.width, height: @pdf.bounds.height#, fit: [@pdf.bounds.width, @pdf.bounds.height]
  end

  def draw_card_content(titre, identifiant, image_path, texte)
    @pdf.move_down 15
    @pdf.text titre, align: :center, size: 14, style: :bold
    

    @pdf.text_box identifiant, size: 14, width: 40, align: :center,
     at: [@pdf.bounds.right - identifiant.length * 1.6 - 46, @pdf.bounds.top - 4]


    # @pdf.text_box identifiant, at: [@pdf.bounds.width - 40- 14, @pdf.bounds.top- 14], width: 40, height: 12, align: :right, size: 8
    @pdf.move_down 10
    @pdf.image image_path, fit: [@pdf.bounds.width - 10, @pdf.bounds.height - 60], position: :center
    @pdf.move_down 30
    @pdf.text_box texte, at: [@pdf.bounds.left + 20, @pdf.bounds.bottom + 90], width: @pdf.bounds.width - 40, height: @pdf.bounds.height - 60, align: :center, size: 10

  end

  
end

# Exemple d'utilisation
font_path = "OpenSans-VariableFont_wdth,wght.ttf" # Remplacez par le chemin vers votre police TTF
carte_pdf = CarteJouerPDF.new(font_path)

carte_pdf.add_carte_from_yaml("animaux.yaml", "fond4.png", "logo.png")
carte_pdf.generate_pdf("cartes-back.pdf")

carte_pdf = CarteJouerPDF.new(font_path)

carte_pdf.add_carte_from_yaml("animaux.yaml", "fond5.png", "logo.png")
carte_pdf.generate_pdf("cartes-back2.pdf")


