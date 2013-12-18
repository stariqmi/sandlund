#!/bin/bash
ruby /home/edgar_submission_scraper/scraper.rb && ruby /home/edgar_submission_scraper/convertor.rb && node /home/edgar_submission_scraper/pusher.js
