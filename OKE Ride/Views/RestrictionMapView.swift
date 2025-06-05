import SwiftUI
import MapKit

/// A tiny capsule‐style battery bar
struct BatteryBar: View {
  let level: Int  // 0–100
  var body: some View {
    ZStack(alignment: .leading) {
      Capsule()
        .fill(Color.gray.opacity(0.3))
      Capsule()
        .fill(level < 20 ? Color.red : Color.green)
        .frame(width: max(0, min(CGFloat(level), 100)) / 100 * 40)
    }
    .frame(width: 40, height: 6)
  }
}

/// The whole pin: circle background, scooter icon, and battery bar
struct ScooterPinView: View {
  let batteryLevel: Int
  var body: some View {
    ZStack {
      Circle()
        .fill(Color.white)
        .frame(width: 50, height: 50)
        .shadow(radius: 3)

      VStack(spacing: 4) {
        Image("scooterIcon")
          .resizable()
          .frame(width: 24, height: 24)

        BatteryBar(level: batteryLevel)
      }
    }
  }
}

struct RestrictionMapView: UIViewRepresentable {
    @Binding var scooters: [Scooter]
    @Binding var region: MKCoordinateRegion
    var userLocation: CLLocationCoordinate2D?
    var onScooterSelected: (Scooter) -> Void

    private func loadZones() -> [MKPolygon] {
        guard
            let url = Bundle.main.url(forResource: "RestrictionZones", withExtension: "geojson"),
            let data = try? Data(contentsOf: url)
        else {
            print("❌ DEBUG: could not find RestrictionZones.geojson in bundle")
            return []
        }
        do {
            let features = try MKGeoJSONDecoder()
                .decode(data)
                .compactMap { $0 as? MKGeoJSONFeature }
            let polys = features.flatMap { $0.geometry.compactMap { $0 as? MKPolygon } }
            print("🔴 DEBUG: loaded \(polys.count) restriction polygons")
            return polys
        } catch {
            print("❌ DEBUG: GeoJSON decode error:", error)
            return []
        }
    }
    // NEW: load the golf-course border LineString(s) as polylines
    private func loadBorder() -> [MKPolyline] {
        guard
            let url  = Bundle.main.url(
                        forResource: "GolfCourseBorder",
                        withExtension: "geojson"),
            let data = try? Data(contentsOf: url)
        else { return [] }

        do {
            let features = try MKGeoJSONDecoder()
                .decode(data)
                .compactMap { $0 as? MKGeoJSONFeature }
            return features.flatMap { feat in
                feat.geometry.compactMap { $0 as? MKPolyline }
            }
        } catch {
            print("❌ Border GeoJSON decode error:", error)
            return []
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
          self,
          zones:   loadZones(),
          borders: loadBorder()
        )
    }

    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        // add restriction polygons
        context.coordinator.zones.forEach { mapView.addOverlay($0) }
        // add golf‐course border lines
        context.coordinator.borders.forEach { mapView.addOverlay($0) }

        // (optional) zoom to fit everything at launch
        let allOverlays = context.coordinator.zones as [MKOverlay] +
                          context.coordinator.borders
        if !allOverlays.isEmpty {
            let rect = allOverlays
                .map { $0.boundingMapRect }
                .reduce(MKMapRect.null) { $0.union($1) }
            mapView.setVisibleMapRect(
              rect,
              edgePadding: .init(top:50,left:50,bottom:50,right:50),
              animated: false
            )
        } else {
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }



    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 1) If overlays got cleared, re-add them
        if mapView.overlays.isEmpty {
          context.coordinator.zones.forEach   { mapView.addOverlay($0) }
          context.coordinator.borders.forEach { mapView.addOverlay($0) }
        }

        // 2) Sync scooters annotations
        let oldScooters = mapView.annotations.compactMap { $0 as? ScooterAnnotation }
        mapView.removeAnnotations(oldScooters)
        let newAnnos = scooters.map { ScooterAnnotation(scooter: $0) }
        mapView.addAnnotations(newAnnos)

        // 3) (Optional) update custom user‐dot similarly…
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent:  RestrictionMapView
        let zones:   [MKPolygon]
        let borders: [MKPolyline]
        var hasShownRestrictedAlert = false

        init(_ parent: RestrictionMapView,
             zones: [MKPolygon],
             borders: [MKPolyline]) {
            self.parent  = parent
            self.zones   = zones
            self.borders = borders
        }
        // Called whenever the blue “user location” dot updates
            func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
                guard let coord = userLocation.location?.coordinate else { return }

                // 1) Hit-test each restriction polygon
                let mapPt = MKMapPoint(coord)
                var insideZone: MKPolygon?
                for zone in zones {
                    let renderer = MKPolygonRenderer(polygon: zone)
                    let pt = renderer.point(for: mapPt)
                    if renderer.path.contains(pt) {
                        insideZone = zone
                        break
                    }
                }

                // 2) If inside and we haven’t shown the alert yet, show it
                if insideZone != nil && !hasShownRestrictedAlert {
                    hasShownRestrictedAlert = true

                    let alert = UIAlertController(
                        title: "Restricted Zone",
                        message: "You are inside a restricted area. Would you like directions to exit?",
                        preferredStyle: .alert
                    )

                    // Dismiss
                    alert.addAction(.init(title: "OK", style: .default, handler: nil))

                    // Navigate out
                    alert.addAction(.init(title: "Navigate Out", style: .default) { _ in
                        // Destination: your initial region center (a known safe point)
                        let destCoord = self.parent.region.center
                        let destPlacemark = MKPlacemark(coordinate: destCoord)
                        let destItem      = MKMapItem(placemark: destPlacemark)
                        destItem.name     = "Safe Area"

                        // Launch Apple Maps walking directions
                        MKMapItem.openMaps(
                          with: [ .forCurrentLocation(), destItem ],
                          launchOptions: [ MKLaunchOptionsDirectionsModeKey:
                                           MKLaunchOptionsDirectionsModeWalking ]
                        )
                    })

                    // Present it
                    DispatchQueue.main.async {
                        mapView.window?.rootViewController?
                            .present(alert, animated: true)
                    }
                }

                // 3) Reset when the user leaves all zones
                if insideZone == nil {
                    hasShownRestrictedAlert = false
                }
            }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if let poly = overlay as? MKPolygon {
                let r = MKPolygonRenderer(polygon: poly)
                r.fillColor   = UIColor.red.withAlphaComponent(0.3)
                r.strokeColor = UIColor.red
                r.lineWidth   = 2
                return r
            }
            
            if let line = overlay as? MKPolyline {
                // dashed red border
                let r = MKPolylineRenderer(polyline: line)
                r.strokeColor    = UIColor.red
                r.lineWidth      = 3
                r.lineDashPattern = [4, 4]  // 4-point dash, 4-point gap
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // handle user‐dot…
            if annotation is MapUserAnnotation {
                let id = "userDot"
                let v = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                      ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                v.annotation = annotation
                v.canShowCallout = false

                let host = UIHostingController(rootView: PulsingDot())
                host.view.backgroundColor = .clear
                host.view.frame = CGRect(x: -20, y: -20, width: 40, height: 40)
                v.addSubview(host.view)
                return v
            }

            // scooter pins…
            if let scoAnno = annotation as? ScooterAnnotation {
                let id = "scooterPin"
                let av = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                       ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                av.annotation = annotation
                av.canShowCallout = false
                av.subviews.forEach { $0.removeFromSuperview() }

                let host = UIHostingController(
                  rootView: ScooterPinView(batteryLevel: scoAnno.scooter.batteryLevel)
                )
                host.view.backgroundColor = .clear
                host.view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                av.addSubview(host.view)

                av.frame = host.view.frame
                av.centerOffset = CGPoint(x: 0, y: -25)
                return av
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let scoAnno = view.annotation as? ScooterAnnotation else { return }
            let mapPt = MKMapPoint(scoAnno.coordinate)

            for zone in zones {
                let renderer = MKPolygonRenderer(polygon: zone)
                let pt = renderer.point(for: mapPt)
                if renderer.path.contains(pt) {
                    let alert = UIAlertController(
                        title: "Cannot Ride Here",
                        message: "This area is restricted.",
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default) { _ in
                            mapView.deselectAnnotation(view.annotation, animated: true)
                        }
                    )
                    UIApplication.shared.windows.first?
                        .rootViewController?
                        .present(alert, animated: true)
                    return
                }
            }

            parent.onScooterSelected(scoAnno.scooter)
        }
    }
}

// Simple MKAnnotation wrappers
class ScooterAnnotation: NSObject, MKAnnotation {
    let scooter: Scooter
    var coordinate: CLLocationCoordinate2D

    init(scooter: Scooter) {
        self.scooter    = scooter
        self.coordinate = CLLocationCoordinate2D(
            latitude: scooter.latitude,
            longitude: scooter.longitude
        )
    }
}

class MapUserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    init(_ coord: CLLocationCoordinate2D) { self.coordinate = coord }
}
