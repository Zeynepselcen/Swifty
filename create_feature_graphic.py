#!/usr/bin/env python3
"""
Google Play Console Feature Graphic Oluşturucu
Swifty Gallery Cleaner için 1024x500 PNG dosyası oluşturur
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_feature_graphic():
    # Canvas oluştur
    width, height = 1024, 500
    image = Image.new('RGBA', (width, height), color='#B24592')
    draw = ImageDraw.Draw(image, 'RGBA')
    
    # Gradient arka plan
    for y in range(height):
        # Mor'dan mavi'ye gradient
        r = int(178 + (y / height) * (30 - 178))  # B24592 -> 1E3C72
        g = int(69 + (y / height) * (60 - 69))    # 69 -> 3C
        b = int(146 + (y / height) * (114 - 146)) # 92 -> 72
        color = (r, g, b)
        draw.line([(0, y), (width, y)], fill=color)
    
    # Dalgalı şekiller
    wave_color1 = (241, 95, 121, 50)  # F15F79 with alpha
    wave_color2 = (109, 50, 122, 30)  # 6D327A with alpha
    
    # Üst dalga
    for x in range(width):
        y1 = int(100 + 50 * (x / width) + 20 * (x % 100) / 100)
        draw.ellipse([x-2, y1-2, x+2, y1+2], fill=wave_color1)
    
    # Alt dalga
    for x in range(width):
        y2 = int(350 + 30 * (x / width) + 15 * (x % 80) / 80)
        draw.ellipse([x-1, y2-1, x+1, y2+1], fill=wave_color2)
    
    # Logo alanı (beyaz daire)
    logo_center = (width // 2, 150)
    logo_radius = 60
    draw.ellipse([
        logo_center[0] - logo_radius,
        logo_center[1] - logo_radius,
        logo_center[0] + logo_radius,
        logo_center[1] + logo_radius
    ], fill='white', outline='#4DB6AC', width=3)
    
    # Logo içinde kamera ikonu
    camera_center = (logo_center[0], logo_center[1] + 5)
    draw.ellipse([
        camera_center[0] - 20,
        camera_center[1] - 15,
        camera_center[0] + 20,
        camera_center[1] + 15
    ], fill='#B24592', outline='#4DB6AC', width=2)
    
    # Kamera lens
    draw.ellipse([
        camera_center[0] - 8,
        camera_center[1] - 8,
        camera_center[0] + 8,
        camera_center[1] + 8
    ], fill='#4DB6AC')
    
    # Ana başlık
    try:
        # Font yükle (varsa)
        font_large = ImageFont.truetype("Arial.ttf", 48)
        font_medium = ImageFont.truetype("Arial.ttf", 24)
    except:
        # Varsayılan font
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
    
    # Başlık
    title = "Swifty Gallery Cleaner"
    title_bbox = draw.textbbox((0, 0), title, font=font_large)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = 250
    
    # Başlık gölgesi
    draw.text((title_x + 2, title_y + 2), title, fill='#1E3C72', font=font_large)
    draw.text((title_x, title_y), title, fill='white', font=font_large)
    
    # Alt başlık
    subtitle = "Akıllı Galeri Temizleyici"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=font_medium)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = 310
    
    draw.text((subtitle_x + 1, subtitle_y + 1), subtitle, fill='#1E3C72', font=font_medium)
    draw.text((subtitle_x, subtitle_y), subtitle, fill='#E0E0E0', font=font_medium)
    
    # Özellik ikonları
    icons = ["📸", "🧹", "⚡", "🔒"]
    icon_y = 380
    icon_spacing = 120
    start_x = (width - (len(icons) - 1) * icon_spacing) // 2
    
    for i, icon in enumerate(icons):
        icon_x = start_x + i * icon_spacing
        # İkon arka planı
        draw.ellipse([
            icon_x - 25, icon_y - 25,
            icon_x + 25, icon_y + 25
        ], fill=(255,255,255,51), outline=(255,255,255,128), width=2)
        
        # İkon metni (emoji yerine basit şekiller)
        if icon == "📸":
            # Kamera
            draw.ellipse([icon_x-8, icon_y-6, icon_x+8, icon_y+6], fill='white')
            draw.ellipse([icon_x-3, icon_y-3, icon_x+3, icon_y+3], fill='#4DB6AC')
        elif icon == "🧹":
            # Temizlik
            draw.rectangle([icon_x-8, icon_y-8, icon_x+8, icon_y+8], fill='white', outline='#4DB6AC', width=2)
        elif icon == "⚡":
            # Hız
            points = [(icon_x, icon_y-10), (icon_x-5, icon_y), (icon_x+5, icon_y), (icon_x, icon_y+10)]
            draw.polygon(points, fill='white', outline='#4DB6AC', width=2)
        elif icon == "🔒":
            # Güvenlik
            draw.rectangle([icon_x-8, icon_y-6, icon_x+8, icon_y+6], fill='white', outline='#4DB6AC', width=2)
            draw.ellipse([icon_x-4, icon_y-8, icon_x+4, icon_y-2], fill='white', outline='#4DB6AC', width=2)
    
    # İndirme butonu
    button_y = 450
    button_width = 200
    button_height = 40
    button_x = (width - button_width) // 2
    
    # Buton arka planı
    draw.rectangle([
        button_x, button_y,
        button_x + button_width, button_y + button_height
    ], fill='#4DB6AC', outline='white', width=2)
    
    # Buton metni
    button_text = "Ücretsiz İndir"
    button_bbox = draw.textbbox((0, 0), button_text, font=font_medium)
    button_text_width = button_bbox[2] - button_bbox[0]
    button_text_x = button_x + (button_width - button_text_width) // 2
    button_text_y = button_y + (button_height - 20) // 2
    
    draw.text((button_text_x, button_text_y), button_text, fill='white', font=font_medium)
    
    return image

if __name__ == "__main__":
    # Feature Graphic oluştur
    feature_graphic = create_feature_graphic()
    
    # PNG olarak kaydet
    output_path = "swifty-gallery-cleaner-feature-graphic.png"
    feature_graphic.save(output_path, "PNG", optimize=True)
    
    print(f"✅ Feature Graphic oluşturuldu: {output_path}")
    print(f"📏 Boyut: 1024x500 piksel")
    print(f"📁 Dosya boyutu: {os.path.getsize(output_path) / 1024:.1f} KB")
    print("\n🎯 Google Play Console'a yüklemek için hazır!") 