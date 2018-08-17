# bycharabot

Бот для IRC, который может построить и зарыть.

## Installation

TODO: Write installation instructions here

## Usage

**Настройка:**  
1. Переименуйте файл `config.template.yml` в `config.yml`
2. Измените по желанию переменные в `config.yml`.  
`server` - адрес сервера.  
`port` - порт сервера.  
`connection_timeout` - таймаут соединения в секундах.  
`vote_kick` - сколько нужно голосов, чтобы бот покинул канал. **На данный момент ничего не делает.**  
`nickname` - имя бота.  
`channels` - массив каналов, к которым бот автоматически подсоединится. **Писать канал нужно без решётки в начале!**  
`regex` - массив регулярных выражений для удаления ненужных символов из сообщения. **Формат: PCRE.**  

**Команды:**  
`любая строка из text.txt, кроме последней` - бот напишет следующую строку.  
`кто такой *имя бота*` - бот ответит `Я - самый полезный бот. Кто не согласен, тот будет построен и зарыт.`  
`~inv #канал` - бот зайдёт на канал из первого аргумента.  
`~leave` - проголосовать за выход бота из сервера. **На данный момент ничего не делает.**  

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/iVAN2002/bycharabot/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [iVAN2002](https://github.com/iVAN2002) Ivan Kuzmenko - creator, maintainer
