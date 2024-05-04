require 'prawn'

class CarteJouerPDF
  def initialize
    @pdf = Prawn::Document.new
    @pdf.font("Helvetica")
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
    @pdf.text titre, align: :center, size: 8, style: :bold
    @pdf.text_box identifiant, at: [@pdf.bounds.width - 40 - 8, @pdf.bounds.top - 8], width: 40, height: 12, align: :right, size: 6
    @pdf.move_down 10
    @pdf.image image_path, fit: [@pdf.bounds.width - 20, @pdf.bounds.height - 60], position: :center
    @pdf.move_down 30
    @pdf.text texte, align: :center, size: 8
  end
  
end

# Exemple d'utilisation
carte_pdf = CarteJouerPDF.new
carte_pdf.add_carte("Titre de la carte 1", "AB", "image1.png", "fond1.png", "Phrase 1\nPhrase 2\nPhrase 3\nPhrase 4", "logo.png")
carte_pdf.add_carte("Titre de la carte 2", "CD", "image2.png", "fond2.png", "Phrase 5\nPhrase 6\nPhrase 7\nPhrase 8", "logo.png")
carte_pdf.generate_pdf("cartes.pdf")
