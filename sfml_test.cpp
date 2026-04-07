#include <SFML/Graphics.hpp>
#include <cstdlib>
#include <ctime>

int main()
{
    // Инициализация генератора случайных чисел
    std::srand(static_cast<unsigned>(std::time(nullptr)));

    // Создание окна 300x400
    sf::RenderWindow window(sf::VideoMode(300, 400), "Pixel by Pixel Fill");

    // Создание текстуры 300x400
    sf::Texture texture;
    texture.create(300, 400);

    // Создание спрайта для отображения текстуры
    sf::Sprite sprite;
    sprite.setTexture(texture);

    // Параметры изображения
    const int width = 300;
    const int height = 400;
    const int pixelCount = width * height;

    // Массив пикселей в формате RGBA (4 байта на пиксель)
    sf::Uint8* pixels = new sf::Uint8[pixelCount * 4];

    // Заполнение каждого пикселя случайным цветом
    for (int y = 0; y < height; ++y)
    {
        for (int x = 0; x < width; ++x)
        {
            int index = (y * width + x) * 4;
            pixels[index + 0] = std::rand() % 256; // Red
            pixels[index + 1] = std::rand() % 256; // Green
            pixels[index + 2] = std::rand() % 256; // Blue
            pixels[index + 3] = 255;               // Alpha (непрозрачный)
        }
    }

    // Обновление текстуры пикселями
    texture.update(pixels);

    // Основной цикл программы
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear(sf::Color::Black);
        window.draw(sprite);
        window.display();
    }

    // Освобождение памяти
    delete[] pixels;

    return 0;
}
