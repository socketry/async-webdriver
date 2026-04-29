# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

# Simple multi-page application used by both test suites.
# Returns different HTML based on the request path.
module App
	PAGES = {
		"/" => {
			title: "Home",
			body: <<~HTML
				<h1 id="heading">Welcome</h1>
				<p id="tagline">The fast browser automation library.</p>
				<nav>
					<a href="/about" id="about-link">About</a>
					<a href="/contact" id="contact-link">Contact</a>
				</nav>
				<form id="search-form" action="/search" method="get">
					<input type="text" id="query" name="q" placeholder="Search...">
					<button type="submit" id="search-btn">Search</button>
				</form>
			HTML
		},
		"/about" => {
			title: "About",
			body: <<~HTML
				<h1 id="heading">About Us</h1>
				<p id="description">We build fast, async-first tools for Ruby developers.</p>
				<a href="/" id="home-link">Home</a>
			HTML
		},
		"/contact" => {
			title: "Contact",
			body: <<~HTML
				<h1 id="heading">Contact</h1>
				<form id="contact-form">
					<input type="text" id="name" name="name" placeholder="Your name">
					<input type="email" id="email" name="email" placeholder="Your email">
					<textarea id="message" name="message" placeholder="Your message"></textarea>
					<button type="submit" id="send-btn">Send</button>
				</form>
				<div id="confirmation" style="display:none">Thank you! We will be in touch.</div>
				<script>
					document.getElementById("contact-form").addEventListener("submit", function(e) {
						e.preventDefault();
						document.getElementById("contact-form").style.display = "none";
						document.getElementById("confirmation").style.display = "block";
					});
				</script>
			HTML
		},
		"/search" => {
			title: "Search Results",
			body: <<~HTML
				<h1 id="heading">Search Results</h1>
				<p id="results">Showing results for your query.</p>
				<a href="/" id="home-link">Back to Home</a>
			HTML
		},
	}.freeze
	
	def self.response_for(path)
		page = PAGES[path] || PAGES["/"]
		html = <<~HTML
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="utf-8">
					<title>#{page[:title]}</title>
				</head>
				<body>
					#{page[:body]}
				</body>
			</html>
		HTML
		[200, {"content-type" => "text/html; charset=utf-8"}, [html]]
	end
end
