# frozen_string_literal: true

require "marcel"
require "stringio"

module Truedocs
  module Utils
    class FileHandler
      MAX_FILE_SIZE = 10 * 1024 * 1024 # 10MB
      SUPPORTED_TYPES = %w[
        image/jpeg
        image/png
        image/tiff
        application/pdf
      ].freeze

      def initialize(file)
        @file = file
      end

      def prepare
        validate_file!

        case @file
        when String
          prepare_file_path(@file)
        when File, IO
          prepare_file_object(@file)
        when Hash
          @file # Already prepared multipart data
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{@file.class}"
        end
      end

      private

      def validate_file!
        case @file
        when String
          validate_file_path(@file)
        when File, IO
          validate_file_object(@file)
        when Hash
          # Assume it's already prepared multipart data
          nil
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{@file.class}"
        end
      end

      def validate_file_path(path)
        raise ValidationError, "File does not exist: #{path}" unless File.exist?(path)

        file_size = File.size(path)
        raise FileTooLargeError, "File too large (#{file_size} bytes)" if file_size > MAX_FILE_SIZE

        mime_type = Marcel::MimeType.for(Pathname.new(path))
        return if SUPPORTED_TYPES.include?(mime_type)

        raise UnsupportedFileTypeError, "Unsupported file type: #{mime_type}"
      end

      def validate_file_object(file)
        file.rewind if file.respond_to?(:rewind)
        content = file.read
        file.rewind if file.respond_to?(:rewind)

        raise FileTooLargeError, "File too large (#{content.size} bytes)" if content.size > MAX_FILE_SIZE

        mime_type = Marcel::MimeType.for(content)
        return if SUPPORTED_TYPES.include?(mime_type)

        raise UnsupportedFileTypeError, "Unsupported file type: #{mime_type}"
      end

      def prepare_file_path(path)
        Faraday::UploadIO.new(path, Marcel::MimeType.for(Pathname.new(path)))
      end

      def prepare_file_object(file)
        file.rewind if file.respond_to?(:rewind)
        content = file.read
        file.rewind if file.respond_to?(:rewind)

        mime_type = Marcel::MimeType.for(content)
        filename = file.respond_to?(:path) ? File.basename(file.path) : "file"

        Faraday::UploadIO.new(StringIO.new(content), mime_type, filename)
      end
    end
  end
end
