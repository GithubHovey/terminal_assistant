#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QObject>
#include <QString>

class ImageProcessor : public QObject
{
    Q_OBJECT

public:
    explicit ImageProcessor(QObject *parent = nullptr);
    ~ImageProcessor() override;

    Q_INVOKABLE bool cropCircular(const QString &inputPath,
                                  const QString &outputPath,
                                  int targetSize,
                                  int offsetX, int offsetY,
                                  double scale,
                                  int previewSize = 200);

    Q_INVOKABLE bool cropRectangular(const QString &inputPath,
                                     const QString &outputPath,
                                     int targetWidth, int targetHeight,
                                     int offsetX, int offsetY,
                                     double scale,
                                     int previewWidth = 200,
                                     int previewHeight = 200);

signals:
    void processingError(const QString &error);
    void processingFinished(const QString &outputPath);
};

#endif // IMAGEPROCESSOR_H
