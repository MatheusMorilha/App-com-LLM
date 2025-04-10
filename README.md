# App-com-LLM
Desenvolver um app em Flutter que se comunique com um LLM (como o Gemini), utilizando um prompt personalizado de acordo com o tema escolhido.

📚 Recomendação de Livros com LLM - Flutter App

Este é um aplicativo Flutter que utiliza um modelo de linguagem de grande porte (LLM), como o **Gemini**, para gerar recomendações personalizadas de livros com base no interesse do usuário.

🎯 Tema Escolhido

Recomendação de Livros
O aplicativo permite que o usuário descreva um assunto ou área de interesse (como "inteligência emocional", "ficção científica", "história medieval", etc.). A partir dessa descrição, o app consulta um LLM e retorna uma lista de livros recomendados, contendo:

- Título do livro  
- Autor  
- Breve descrição do conteúdo

💬 Prompt Utilizado

```text
Baseado na descrição informada: "$prompUserText"

Recomende os principais e mais populares livros que se enquadram no assunto. Traga as informações de título do livro, autor e uma breve descrição do que se trata.
