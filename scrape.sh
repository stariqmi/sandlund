#!/bin/bash
ruby scraper.rb && ruby convertor.rb && node pusher.js
