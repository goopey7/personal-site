---
layout: default
title: Home
---

# Sam Collier

Game Developer and Entrepeneur. Currently learning more about low level systems.

---

## Latest Blog Posts

<div class="horizontal-grid">
  {% for post in site.posts limit:2 %}
    <a href="{{ post.url }}" class="post-card">
      <img src="{{ post.thumbnail | default: '/assets/thumbs/default.png' }}" alt="Thumbnail">
      <div class="post-info">
        <h2>{{ post.title }}</h2>
        <p class="meta">{{ post.date | date: "%B %d, %Y" }}</p>
        <p>{{ post.description }}</p>
      </div>
    </a>
  {% endfor %}
</div>

<p class="see-more"><a href="/blog.html">See more blog posts →</a></p>

---

## Portfolio

<div class="horizontal-grid">
  {% assign portfolio_items = site.portfolio | slice: 0, 2 %}
  {% for item in portfolio_items %}
    <a href="{{ item.url }}" class="post-card">
      <img src="{{ item.thumbnail | default: '/assets/thumbs/default.png' }}" alt="Thumbnail">
      <div class="post-info">
        <h2>{{ item.title }}</h2>
        <p class="meta">{{ item.date | date: "%B %d, %Y" }}</p>
        <p>{{ item.description }}</p>
      </div>
    </a>
  {% endfor %}
</div>

<p class="see-more"><a href="/portfolio.html">See more portfolio work →</a></p>

