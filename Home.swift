//
//  Home.swift
//  AutosizingTextField
//
//  Created by Maxim Macari on 8/5/21.
//

import SwiftUI

struct Home: View {
    
    @State var text = ""
    
    //Auto updating textbox height
    @State var containerHeight: CGFloat = 0
    let MAX_HEIGHT: CGFloat = 120
    
    var body: some View {
        NavigationView {
            VStack{
                
                AutoSizingTF(hint: "Write something", text: $text, containerHeight: $containerHeight, onEnd: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                })
                    .padding(.horizontal)
                    .frame(height: containerHeight <= MAX_HEIGHT ? containerHeight : MAX_HEIGHT)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                
            }
            .navigationTitle("Input accessory view")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.04).ignoresSafeArea())
        }
    }
}

struct AutoSizingTF: UIViewRepresentable {
    
    
    var hint: String
    @Binding var text: String
    @Binding var containerHeight: CGFloat
    var onEnd: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return AutoSizingTF.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = hint
        textView.textColor = .gray
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 20)
        
        //setting delegate
        textView.delegate = context.coordinator
        
        //input accessory vieew
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolBar.barStyle = .default
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.closeKeyboard))
        toolBar.items = [
            spacer,
            doneButton
        ]
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // starting textfield height
        DispatchQueue.main.async {
            if containerHeight == 0 {
                containerHeight = uiView.contentSize.height
            }
        }
        
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        //to read all parent properties
        var parent: AutoSizingTF
        
        init(parent: AutoSizingTF) {
            self.parent = parent
        }
        
        //keyboard close @objc function
        @objc func closeKeyboard() {
            parent.onEnd()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            //Chek if textbox is empty -> clear hint
            if textView.text == parent.hint {
                textView.text = ""
                textView.textColor = UIColor(Color.primary)
            }
        }
        
        //updating text in SwiftUI view
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
        }
        
        // on end cheking if textvox is empty -> show hint
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = parent.hint
                textView.textColor = .gray
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
