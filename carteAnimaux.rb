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
    animaux =  YAML.load_file(yaml_file)
    
    animaux.each do |animal|
      animal["image"] = "images/#{animal['Nom'].downcase.gsub(' ', '_')}.png"
      add_carte(animal["Nom"], animal["Prix"], animal["image"], fond_path, animal["Capacité"], carte_logo_path)
    end
  end

  def add_carte(titre, identifiant, image_path, fond_path, texte, carte_logo_path)
    card_width = mm_to_pt(62)
    card_height = mm_to_pt(88)

    if @pdf.cursor < card_height
      @pdf.start_new_page
    end

    @pdf.bounding_box([0, @pdf.cursor], width: card_width, height: card_height) do
      draw_card_background(fond_path)
      draw_rounded_card
      draw_logo(carte_logo_path)
      draw_card_content(titre, identifiant, image_path, texte)
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

  def draw_logo(carte_logo_path)
    @pdf.image carte_logo_path, at: [5, @pdf.cursor - 5], width: 20, height: 20
  end

  def draw_card_background(fond_path)
    @pdf.image fond_path, at: [0, @pdf.cursor], width: @pdf.bounds.width, height: @pdf.bounds.height#, fit: [@pdf.bounds.width, @pdf.bounds.height]
  end

  def draw_card_content(titre, identifiant, image_path, texte)
    @pdf.move_down 15
    @pdf.text titre, align: :center, size: 14, style: :bold
    @pdf.text_box identifiant, at: [@pdf.bounds.width - 40- 14, @pdf.bounds.top- 14], width: 40, height: 12, align: :right, size: 8
    @pdf.move_down 10
    @pdf.image image_path, fit: [@pdf.bounds.width - 10, @pdf.bounds.height - 60], position: :center
    @pdf.move_down 30
    @pdf.text_box texte, at: [@pdf.bounds.left + 20, @pdf.bounds.bottom + 90], width: @pdf.bounds.width - 40, height: @pdf.bounds.height - 60, align: :center, size: 10

  end
  
end

# Exemple d'utilisation
font_path = "OpenSans-VariableFont_wdth,wght.ttf" # Remplacez par le chemin vers votre police TTF
carte_pdf = CarteJouerPDF.new(font_path)

carte_pdf.add_carte_from_yaml("animaux.yaml", "fond1.png", "logo.png")
# carte_pdf.add_carte("Titre de la carte 1", "AB", "image1.png", "fond1.png", "Phrase 1\nPhrase 2\nPhrase 3\nPhrase 4", "logo.png")
#carte_pdf.add_carte("Titre de la carte 2", "CD", "image2.png", "fond2.png", "Phrase 5\nPhrase 6\nPhrase 7\nPhrase 8", "logo.png")
carte_pdf.generate_pdf("cartes.pdf")


